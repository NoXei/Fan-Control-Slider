/* -*- mode: js2 - indent-tabs-mode: nil - js2-basic-offset: 4 -*- */

'use strict';

import Gio from 'gi://Gio';
import GObject from 'gi://GObject';
import St from 'gi://St';
import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';

import { Extension, gettext as _ } from 'resource:///org/gnome/shell/extensions/extension.js';

import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as PanelMenu from 'resource:///org/gnome/shell/ui/panelMenu.js';
import * as PopupMenu from 'resource:///org/gnome/shell/ui/popupMenu.js';
import * as Slider from 'resource:///org/gnome/shell/ui/slider.js';

const FAN_CONTROL_PATH = '/proc/acpi/ibm/fan';
const THERMAL_PATH = '/proc/acpi/ibm/thermal';

function getFanLevels() {
    // Return translated fan levels (SAFE LEVELS ONLY - no disengaged/full-speed)
    return [
        { value: 0, label: _('Auto'), command: 'level auto' },
        { value: 1, label: _('Level 0'), command: 'level 0' },
        { value: 2, label: _('Level 1'), command: 'level 1' },
        { value: 3, label: _('Level 2'), command: 'level 2' },
        { value: 4, label: _('Level 3'), command: 'level 3' },
        { value: 5, label: _('Level 4'), command: 'level 4' },
        { value: 6, label: _('Level 5'), command: 'level 5' },
        { value: 7, label: _('Level 6'), command: 'level 6' },
        { value: 8, label: _('Level 7 (Max Safe)'), command: 'level 7' }
    ];
}

const ThinkPadFanIndicator = GObject.registerClass(
class ThinkPadFanIndicator extends PanelMenu.Button {
    _init(extension) {
        super._init(0.0, _('ThinkPad Fan Control'));

        this._extension = extension;
        this._settings = extension.getSettings();
        this._currentLevel = 0; // 0 = auto, 1-8 = levels 0-7, 9 = full-speed
        this._temperature = 0;

        // Create the panel icon and label
        this._box = new St.BoxLayout({
            style_class: 'panel-status-menu-box'
        });

        // Fan icon
        this._icon = new St.Icon({
            icon_name: 'weather-windy-symbolic',
            style_class: 'system-status-icon'
        });
        this._box.add_child(this._icon);

        // Temperature label (optional)
        this._temperatureLabel = new St.Label({
            text: '',
            style_class: 'temperature-label',
            y_align: Clutter.ActorAlign.CENTER
        });
        this._box.add_child(this._temperatureLabel);

        this.add_child(this._box);

        // Build menu
        this._buildMenu();

        // Initialize fan status
        this._updateFanStatus();
        this._updateTemperature();

        // Set up periodic updates
        this._setupTimer();

        // Connect settings
        this._settings.connectObject(
            'changed::show-temperature', () => this._updateTemperatureVisibility(),
            'changed::show-notifications', () => {},
            this
        );

        this._updateTemperatureVisibility();
    }

    _buildMenu() {
        // Current status section
        this._statusItem = new PopupMenu.PopupMenuItem(_('Loading...'), {
            reactive: false,
            style_class: 'fan-status-item'
        });
        this.menu.addMenuItem(this._statusItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // Fan level label
        this._levelLabel = new PopupMenu.PopupMenuItem(_('Fan Level: Auto'), {
            reactive: false,
            style_class: 'fan-level-label'
        });
        this.menu.addMenuItem(this._levelLabel);

        // Fan level slider
        this._slider = new Slider.Slider(0);
        this._sliderSignalId = this._slider.connect('notify::value', () => {
            // Prevent recursive updates
            if (this._updatingSlider) {
                return;
            }
            
            const fanLevels = getFanLevels();
            // Clamp slider value to prevent out-of-bounds
            const clampedValue = Math.max(0, Math.min(1, this._slider.value));
            const level = Math.round(clampedValue * (fanLevels.length - 1));
            
            // Safety check
            if (level >= 0 && level < fanLevels.length) {
                this._setFanLevel(level);
            }
        });

        // Create slider menu item
        this._sliderItem = new PopupMenu.PopupBaseMenuItem({ activate: false });
        const sliderBox = new St.BoxLayout({
            vertical: false,
            x_expand: true,
            style: 'padding: 6px 12px;'
        });

        // Add labels for slider positions
        const leftLabel = new St.Label({
            text: _('Auto'),
            style_class: 'slider-label',
            y_align: Clutter.ActorAlign.CENTER
        });
        
        const rightLabel = new St.Label({
            text: _('L7'),
            style_class: 'slider-label',
            y_align: Clutter.ActorAlign.CENTER
        });

        sliderBox.add_child(leftLabel);
        sliderBox.add_child(this._slider);
        sliderBox.add_child(rightLabel);

        this._sliderItem.add_child(sliderBox);
        this.menu.addMenuItem(this._sliderItem);

        // Level descriptions
        this._descriptionItem = new PopupMenu.PopupMenuItem(_('Automatic fan control'), {
            reactive: false,
            style_class: 'fan-description'
        });
        this.menu.addMenuItem(this._descriptionItem);

        this.menu.addMenuItem(new PopupMenu.PopupSeparatorMenuItem());

        // Emergency auto button (shown when disengaged)
        this._emergencyAutoButton = new PopupMenu.PopupMenuItem(_('⚠️ Emergency: Switch to Auto'), {
            style_class: 'emergency-auto-button'
        });
        this._emergencyAutoButton.connect('activate', () => {
            this._setFanLevel(0); // Set to auto
        });
        this._emergencyAutoButton.visible = false; // Hidden by default
        this.menu.addMenuItem(this._emergencyAutoButton);

        // Enable slider by default
        this._setSliderSensitive(true);

        // Refresh button
        this.menu.addAction(_('Refresh'), () => {
            this._updateFanStatus();
            this._updateTemperature();
        });

        // Settings button
        this.menu.addAction(_('Settings'), () => {
            this._extension.openPreferences();
        });
    }

    async _setFanLevel(level) {
        try {
            const fanLevels = getFanLevels();
            // Validate level range
            if (level < 0 || level >= fanLevels.length) {
                console.error('Invalid fan level:', level);
                return;
            }

            const fanLevel = fanLevels[level];
            const command = fanLevel.command;
            const modeText = fanLevel.label;

            // Check if fan control is available
            const fanFile = Gio.File.new_for_path(FAN_CONTROL_PATH);
            if (!fanFile.query_exists(null)) {
                Main.notify(_('ThinkPad Fan Control'), _('Fan control not available'));
                return;
            }

            // Try using sudo with NOPASSWD first (safer than pkexec)
            let fullCommand = `sudo -n sh -c 'echo "${command}" > ${FAN_CONTROL_PATH}'`;
            
            try {
                const [success, stdout, stderr] = await GLib.spawn_command_line_sync(fullCommand);
                
                if (success) {
                    this._currentLevel = level;
                    this._updateSliderPosition();
                    this._updateLevelLabel();
                    this._updateFanStatus();
                    
                    if (this._settings.get_boolean('show-notifications')) {
                        Main.notify(_('ThinkPad Fan Control'), _(`Fan level changed to: ${modeText}`));
                    }
                    return;
                } else {
                    // If sudo fails, show instructions instead of using pkexec
                    const decoder = new TextDecoder();
                    const errorMsg = decoder.decode(stderr);
                    
                    if (errorMsg.includes('password') || errorMsg.includes('sudo')) {
                        Main.notify(_('ThinkPad Fan Control'), 
                            _('Setup required: Run "sudo visudo" and add this line:\n%sudo ALL=(ALL) NOPASSWD: /bin/sh -c echo * > /proc/acpi/ibm/fan'));
                    } else {
                        Main.notify(_('ThinkPad Fan Control'), _(`Failed: ${errorMsg}`));
                    }
                }
            } catch (sudoError) {
                // Fallback: show manual command instead of risking freeze
                Main.notify(_('ThinkPad Fan Control'), 
                    _(`Manual command needed:\nsudo sh -c 'echo "${command}" > ${FAN_CONTROL_PATH}'`));
            }
            
        } catch (e) {
            console.error('Failed to set fan level:', e);
            Main.notify(_('ThinkPad Fan Control'), _('Operation cancelled to prevent system freeze.'));
        }
    }

    async _updateFanStatus() {
        try {
            // Check if fan control file exists
            const fanFile = Gio.File.new_for_path(FAN_CONTROL_PATH);
            if (!fanFile.query_exists(null)) {
                this._statusItem.label.text = _('ThinkPad fan control not available');
                this._setSliderSensitive(false);
                return;
            }

            // Read current fan status
            const [success, contents] = await GLib.file_get_contents(FAN_CONTROL_PATH);
            
            if (success) {
                const decoder = new TextDecoder();
                const fanData = decoder.decode(contents);
                
                // Parse fan status
                this._parseFanStatus(fanData);
                this._setSliderSensitive(true);
            } else {
                this._statusItem.label.text = _('Cannot read fan status');
                this._setSliderSensitive(false);
            }
        } catch (e) {
            console.error('Failed to read fan status:', e);
            this._statusItem.label.text = _('Error reading fan status');
            this._setSliderSensitive(false);
        }
    }

    _parseFanStatus(fanData) {
        const lines = fanData.trim().split('\n');
        let status = _('Unknown');
        let speed = '';
        let currentLevel = 0;
        let isDisengaged = false;

        for (const line of lines) {
            if (line.startsWith('status:')) {
                status = line.split(':')[1].trim();
            } else if (line.startsWith('speed:')) {
                const speedValue = line.split(':')[1].trim();
                speed = speedValue !== '0' ? ` (${speedValue} RPM)` : '';
            } else if (line.startsWith('level:')) {
                const level = line.split(':')[1].trim();
                if (level === 'disengaged') {
                    isDisengaged = true;
                    currentLevel = 8; // Set slider to level 7 position (max safe)
                } else {
                    // Map fan level to slider position
                    currentLevel = this._mapFanLevelToSliderPosition(level);
                }
            }
        }

        this._currentLevel = currentLevel;
        this._isDisengaged = isDisengaged;
        
        // Show special warning for disengaged mode
        if (isDisengaged) {
            this._statusItem.label.text = _(`⚠️ DISENGAGED${speed} - No thermal protection!`);
        } else {
            this._statusItem.label.text = _(`Status: ${status}${speed}`);
        }
        
        this._updateSliderPosition();
        this._updateLevelLabel();
        this._updatePanelIcon();
    }

    _mapFanLevelToSliderPosition(fanLevel) {
        // Map the current fan level from /proc/acpi/ibm/fan to our slider position
        const fanLevels = getFanLevels();
        for (let i = 0; i < fanLevels.length; i++) {
            const level = fanLevels[i];
            if (level.command === `level ${fanLevel}`) {
                return i;
            }
        }
        
        // Handle special cases
        if (fanLevel === 'auto') return 0;
        if (fanLevel === 'full-speed') return 8; // Map to level 7 (max safe)
        // Note: disengaged is handled separately in _parseFanStatus
        
        // If it's a numeric level (0-7), map it to positions 1-8
        const numLevel = parseInt(fanLevel);
        if (!isNaN(numLevel) && numLevel >= 0 && numLevel <= 7) {
            return numLevel + 1; // positions 1-8 correspond to levels 0-7
        }
        
        return 0; // Default to auto
    }

    _updateSliderPosition() {
        // Update slider without triggering the callback
        const fanLevels = getFanLevels();
        if (!this._slider || !fanLevels || fanLevels.length === 0) {
            return;
        }
        
        // Set a flag to prevent recursive calls
        this._updatingSlider = true;
        this._slider.value = this._currentLevel / (fanLevels.length - 1);
        this._updatingSlider = false;
    }

    _updateLevelLabel() {
        const fanLevels = getFanLevels();
        const fanLevel = fanLevels[this._currentLevel];
        
        if (this._isDisengaged) {
            this._levelLabel.label.text = _('Fan Level: Disengaged');
            this._emergencyAutoButton.visible = true; // Show emergency button
        } else {
            this._levelLabel.label.text = _(`Fan Level: ${fanLevel.label}`);
            this._emergencyAutoButton.visible = false; // Hide emergency button
        }
        
        // Update description
        let description;
        if (this._isDisengaged) {
            description = _('⚠️ DANGER: Fan disengaged - No thermal protection!');
        } else {
            switch (this._currentLevel) {
                case 0:
                    description = _('Automatic fan control');
                    break;
                case 8:
                    description = _('Maximum safe manual level');
                    break;
                default:
                    const levelNum = this._currentLevel - 1;
                    description = _(`Manual fan level ${levelNum}`);
            }
        }
        this._descriptionItem.label.text = description;
    }

    async _updateTemperature() {
        if (!this._settings.get_boolean('show-temperature')) {
            return;
        }

        try {
            const thermalFile = Gio.File.new_for_path(THERMAL_PATH);
            if (!thermalFile.query_exists(null)) {
                return;
            }

            const [success, contents] = await GLib.file_get_contents(THERMAL_PATH);
            
            if (success) {
                const decoder = new TextDecoder();
                const thermalData = decoder.decode(contents);
                
                // Parse temperature (usually first value is CPU temp)
                const match = thermalData.match(/temperatures:\s*(\d+)/);
                if (match) {
                    this._temperature = parseInt(match[1]);
                    this._temperatureLabel.text = `${this._temperature}°C`;
                }
            }
        } catch (e) {
            console.error('Failed to read temperature:', e);
        }
    }

    _updatePanelIcon() {
        // Change icon based on fan level and disengaged state
        if (this._isDisengaged) {
            // Disengaged - use warning icon
            this._icon.icon_name = 'dialog-warning-symbolic';
        } else if (this._currentLevel === 0) {
            // Auto mode
            this._icon.icon_name = 'weather-windy-symbolic';
        } else if (this._currentLevel === 8) {
            // Level 7 (max safe)
            this._icon.icon_name = 'weather-storm-symbolic';
        } else if (this._currentLevel >= 1 && this._currentLevel <= 4) {
            // Low to medium levels (0-3)
            this._icon.icon_name = 'weather-windy-symbolic';
        } else {
            // High levels (4-7)
            this._icon.icon_name = 'weather-storm-symbolic';
        }
    }

    _setSliderSensitive(sensitive) {
        if (this._slider) {
            this._slider.reactive = sensitive;
        }
        if (this._sliderItem) {
            this._sliderItem.setSensitive(sensitive);
        }
    }

    _updateTemperatureVisibility() {
        const showTemp = this._settings.get_boolean('show-temperature');
        this._temperatureLabel.visible = showTemp;
        
        if (showTemp) {
            this._updateTemperature();
        }
    }

    _setupTimer() {
        // Update every 5 seconds
        this._timerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
            this._updateFanStatus();
            this._updateTemperature();
            return GLib.SOURCE_CONTINUE;
        });
    }

    destroy() {
        if (this._timerId) {
            GLib.source_remove(this._timerId);
            this._timerId = null;
        }

        if (this._sliderSignalId && this._slider) {
            this._slider.disconnect(this._sliderSignalId);
            this._sliderSignalId = null;
        }

        if (this._settings) {
            this._settings.disconnectObject(this);
        }

        super.destroy();
    }
});

export default class ThinkPadFanControlExtension extends Extension {
    enable() {
        this._indicator = new ThinkPadFanIndicator(this);
        Main.panel.addToStatusArea('thinkpad-fan-control', this._indicator);
    }

    disable() {
        if (this._indicator) {
            this._indicator.destroy();
            this._indicator = null;
        }
    }
}
