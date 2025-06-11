# ThinkPad Fan Control Extension

A GNOME Shell extension that provides safe, slider-based control over ThinkPad fan speeds directly from the top panel with comprehensive safety features.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/NoXei/Fan-Control-Slider.git
cd Fan-Control-Slider

# Install everything automatically
./install.sh

# Verify installation
./test.sh
```

That's it! Look for the fan icon in your top panel. 🌪️

## 🎯 Features

- **Slider Interface**: Smooth control from Auto → Level 0-7 (Max Safe)
- **Real-time Monitoring**: Live fan speed (RPM) and status updates
- **Temperature Display**: Optional CPU temperature in the panel
- **Safety First**: No dangerous disengaged mode access via slider
- **Visual Feedback**: Different icons for fan states and warnings
- **Emergency Controls**: Auto button appears if fan enters dangerous disengaged state
- **Sudo Integration**: Safe command execution without system freezes

## 🛡️ Safety Features

### Smart Level Mapping
- **Auto Mode**: BIOS-controlled thermal management
- **Levels 0-7**: Manual control with thermal protection
- **Level 7 Max**: Highest safe manual speed (no thermal protection disable)
- **Disengaged Detection**: Automatic warnings if system enters dangerous state

### Security
- **No pkexec**: Uses sudo to prevent system freezes
- **Setup Script**: Configures passwordless sudo for fan control only
- **Command Validation**: Prevents execution of invalid or dangerous commands
- **Emergency Recovery**: Quick return to auto mode when needed

## 📋 Requirements

- **ThinkPad Laptop** with fan control support
- **Linux** with `thinkpad_acpi` module
- **GNOME Shell** 45+
- **Sudo Access** for fan control commands

## 🚀 Installation

### Quick Install (Recommended)

1. **Clone the repository**:
```bash
git clone https://github.com/NoXei/Fan-Control-Slider.git
cd Fan-Control-Slider
```

2. **Run the installation script**:
```bash
./install.sh
```

The script will:
- ✅ Check system requirements
- 📁 Install the extension to the correct location
- 🔐 Guide you through sudo configuration
- 🔧 Configure ThinkPad ACPI module
- ✅ Enable the extension

### Manual Installation

If you prefer to install manually:

#### 1. Extension Setup
```bash
# Clone and navigate to the repository
git clone https://github.com/NoXei/Fan-Control-Slider.git
cd Fan-Control-Slider

# Copy extension to GNOME extensions directory
cp -r thinkpad-fan-control@noxei.dev ~/.local/share/gnome-shell/extensions/

# Compile schemas
glib-compile-schemas ~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev/schemas/

# Enable the extension
gnome-extensions enable thinkpad-fan-control@noxei.dev
```

#### 2. Security Setup (Required)
```bash
# Run the included setup script for safe sudo configuration
cd ~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev/
chmod +x setup.sh
./setup.sh
```

#### 3. ThinkPad ACPI Module Setup
```bash
# Enable fan control in thinkpad_acpi module
echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf

# Reload the module
sudo modprobe -r thinkpad_acpi
sudo modprobe thinkpad_acpi

# Verify fan control is available
cat /proc/acpi/ibm/fan
```

#### 4. Restart GNOME Shell
- **X11**: Press `Alt+F2`, type `r`, press Enter
- **Wayland**: Log out and log back in

### Uninstallation

To completely remove the extension:

```bash
# Navigate to the cloned repository
cd Fan-Control-Slider

# Run the uninstall script
./uninstall.sh
```

The uninstall script will:
- 🔄 Disable the extension
- 🗑️ Remove all extension files
- 🔐 Optionally remove sudo configuration
- 🔧 Reset fan to automatic control
- 🧹 Clean up system configuration

### Testing Installation

To verify your installation is working correctly:

```bash
# Run the test script
./test.sh
```

The test script checks:
- ✅ Extension files and structure
- 🔧 GSettings schemas compilation
- 🌪️ ThinkPad fan control availability
- 🔐 Sudo configuration
- 🖥️ GNOME Shell compatibility
- 📊 Overall installation health

## 🎮 Usage

### Basic Control
1. **Panel Icon**: Look for the fan icon in your top panel
2. **Click to Open**: Click the icon to reveal the control menu
3. **Slider Control**: Drag the slider for precise fan level control:
   - **Far Left**: Auto mode (recommended)
   - **Middle Positions**: Manual levels 0-6
   - **Far Right**: Level 7 (maximum safe speed)

### Interface Elements
- **Status Line**: Shows current fan status and RPM
- **Level Label**: Displays current fan level
- **Slider**: Interactive control (Auto → L7)
- **Description**: Explains current mode
- **Emergency Button**: Appears only if system enters disengaged mode

## 📊 Fan Levels Explained

| Position | Level | Description | Safety |
|----------|-------|-------------|---------|
| 0 | Auto | BIOS thermal control | ✅ Safe |
| 1-8 | Levels 0-7 | Manual control with thermal protection | ✅ Safe |
| Detected | Disengaged | No thermal protection (dangerous) | ⚠️ Warning |

### Important Notes
- **Level 7**: Maximum safe manual control
- **Disengaged**: Never accessible via slider (safety feature)
- **Auto Mode**: Recommended for daily use
- **Manual Levels**: Use when you need specific fan behavior

## ⚙️ Settings

Access via extension menu → Settings:

### Display Options
- **Show Temperature**: Display CPU temp next to fan icon
- **Show Notifications**: Get alerts when fan mode changes

### Behavior Options  
- **Auto Mode on Suspend**: Safety feature for sleep/wake

### Information Panel
- System requirements and setup status
- Safety warnings and best practices

## 🔧 Technical Details

### File Locations
- **Fan Control**: `/proc/acpi/ibm/fan`
- **Temperature**: `/proc/acpi/ibm/thermal`  
- **Sudo Config**: `/etc/sudoers.d/thinkpad-fan-control`
- **Extension**: `~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev/`
- **Repository**: Cloned to your chosen directory (e.g., `~/Fan-Control-Slider/`)

### Command Examples
```bash
# Manual fan level setting (what the extension does)
sudo sh -c 'echo "level 3" > /proc/acpi/ibm/fan'
sudo sh -c 'echo "level auto" > /proc/acpi/ibm/fan'

# Check current status
cat /proc/acpi/ibm/fan
cat /proc/acpi/ibm/thermal
```

## 🚨 Safety Notes

### ⚠️ Critical Safety Information
- **Never disable thermal protection** unless absolutely necessary
- **Monitor temperatures** when using manual levels for extended periods
- **Use Auto mode** for normal daily operation
- **Level 7** is the maximum safe manual setting

### ✅ Safe Practices
- Start with low manual levels and increase gradually
- Return to Auto mode when done with manual control
- Watch CPU temperatures, especially above 80°C
- Use the emergency auto button if system becomes unstable

### 🔥 Temperature Guidelines
- **< 60°C**: All levels safe
- **60-80°C**: Use caution with high manual levels
- **> 80°C**: Return to Auto mode immediately

## 🐛 Troubleshooting

### Extension Not Appearing
```bash
# Check if extension is installed
ls ~/.local/share/gnome-shell/extensions/ | grep thinkpad

# Check if extension is enabled
gnome-extensions list --enabled | grep thinkpad

# Check for errors in system logs
journalctl -f | grep thinkpad

# Restart GNOME Shell
# X11: Alt+F2, type 'r', press Enter
# Wayland: Log out and log back in
```

### Installation Issues
```bash
# Re-run the installation script
cd /path/to/Fan-Control-Slider
./install.sh

# Or reinstall manually
rm -rf ~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev
cp -r thinkpad-fan-control@noxei.dev ~/.local/share/gnome-shell/extensions/
glib-compile-schemas ~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev/schemas/
```

### Permission Errors
```bash
# Re-run setup script
cd ~/.local/share/gnome-shell/extensions/thinkpad-fan-control@noxei.dev/
./setup.sh

# Verify sudo configuration
sudo cat /etc/sudoers.d/thinkpad-fan-control

# Check the exact sudoers entry format
cat /etc/sudoers.d/thinkpad-fan-control
```

### Fan Control Not Working
```bash
# Check thinkpad_acpi module is loaded
lsmod | grep thinkpad_acpi

# Check if fan control interface exists
ls -la /proc/acpi/ibm/fan

# Check current fan status
cat /proc/acpi/ibm/fan

# Reload module with fan control enabled
sudo modprobe -r thinkpad_acpi
sudo modprobe thinkpad_acpi fan_control=1

# Verify configuration file
cat /etc/modprobe.d/thinkpad_acpi.conf
```

### Extension Errors
```bash
# Check extension logs
journalctl --user -f | grep thinkpad

# Check GNOME Shell logs
journalctl -u gdm -f

# Reset extension settings
gsettings reset-recursively org.gnome.shell.extensions.thinkpad-fan-control

# Reinstall completely
gnome-extensions uninstall thinkpad-fan-control@noxei.dev
./install.sh
```

## 📝 Development History

This extension evolved through several development phases, prioritizing safety:

1. **Initial Development** (v1.0): Basic ThinkPad fan control functionality
2. **Safety Crisis Resolution**: Fixed dangerous pkexec system freezes
3. **UI Enhancement**: Implemented smooth slider interface
4. **Safety Hardening**: Removed dangerous disengaged access from UI
5. **Current Version** (v2.0): Comprehensive safety features with emergency controls and professional packaging

## 🔗 Key Learnings

- **Safety First**: Hardware control extensions must prioritize user safety
- **System Integration**: Understanding hardware behavior is crucial (full-speed ≠ disengaged)
- **UI Design**: Sliders provide better control than discrete buttons
- **Error Handling**: Robust error handling prevents system instability
- **Documentation**: Clear safety warnings prevent user mistakes
- **Professional Standards**: Proper versioning, documentation, and installation processes

## 📄 License

GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 👥 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines and contribution process.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/NoXei/Fan-Control-Slider/issues)
- **Documentation**: This README and inline help
- **Safety Questions**: Always prioritize thermal protection

## ⚠️ Disclaimer

This extension controls hardware thermal management. While designed with safety features, users must understand the risks. Monitor temperatures and use responsibly. The authors are not liable for hardware damage from misuse.

---

**🎉 Enjoy safe and precise fan control on your ThinkPad!**
