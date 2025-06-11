/* -*- mode: js2 - indent-tabs-mode: nil - js2-basic-offset: 4 -*- */

'use strict';

import Gtk from 'gi://Gtk';
import Adw from 'gi://Adw';

import { ExtensionPreferences, gettext as _ } from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

export default class ThinkPadFanControlPreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        const settings = this.getSettings();

        // Create the main page
        const page = new Adw.PreferencesPage({
            title: _('General'),
            icon_name: 'preferences-system-symbolic'
        });
        window.add(page);

        // Display Settings Group
        const displayGroup = new Adw.PreferencesGroup({
            title: _('Display Settings'),
            description: _('Control what information is shown in the panel')
        });
        page.add(displayGroup);

        // Show Temperature Toggle
        const tempRow = new Adw.SwitchRow({
            title: _('Show Temperature'),
            subtitle: _('Display CPU temperature next to the fan icon'),
            active: settings.get_boolean('show-temperature')
        });
        tempRow.connect('notify::active', () => {
            settings.set_boolean('show-temperature', tempRow.active);
        });
        displayGroup.add(tempRow);

        // Behavior Settings Group
        const behaviorGroup = new Adw.PreferencesGroup({
            title: _('Behavior'),
            description: _('Configure extension behavior')
        });
        page.add(behaviorGroup);

        // Auto mode on suspend
        const suspendRow = new Adw.SwitchRow({
            title: _('Auto Mode on Suspend'),
            subtitle: _('Automatically switch to auto mode when system suspends'),
            active: settings.get_boolean('auto-mode-on-suspend')
        });
        suspendRow.connect('notify::active', () => {
            settings.set_boolean('auto-mode-on-suspend', suspendRow.active);
        });
        behaviorGroup.add(suspendRow);

        // Show notifications
        const notifRow = new Adw.SwitchRow({
            title: _('Show Notifications'),
            subtitle: _('Show notifications when fan mode changes'),
            active: settings.get_boolean('show-notifications')
        });
        notifRow.connect('notify::active', () => {
            settings.set_boolean('show-notifications', notifRow.active);
        });
        behaviorGroup.add(notifRow);

        // Information Group
        const infoGroup = new Adw.PreferencesGroup({
            title: _('Information'),
            description: _('About ThinkPad Fan Control')
        });
        page.add(infoGroup);

        // Requirements info
        const reqRow = new Adw.ActionRow({
            title: _('Requirements'),
            subtitle: _('This extension requires a ThinkPad with fan control support via /proc/acpi/ibm/fan')
        });
        infoGroup.add(reqRow);

        // Permissions info
        const permRow = new Adw.ActionRow({
            title: _('Permissions'),
            subtitle: _('Root access is required to change fan modes. The extension uses sudo for authentication.')
        });
        infoGroup.add(permRow);

        // Safety warning
        const warningRow = new Adw.ActionRow({
            title: _('⚠️ Warning'),
            subtitle: _('Monitor temperatures when using manual fan levels to prevent overheating.')
        });
        warningRow.add_css_class('warning');
        infoGroup.add(warningRow);
    }
}
