#!/bin/bash

# ThinkPad Fan Control Extension - Installation Script
# This script installs the GNOME Shell extension properly

set -e  # Exit on any error

EXTENSION_UUID="thinkpad-fan-control@noxei.dev"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/$EXTENSION_UUID"

echo "🔧 ThinkPad Fan Control Extension - Installation Script"
echo "=================================================="
echo ""

# Check if we're in the right directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Extension source directory not found at $SOURCE_DIR"
    echo "Please run this script from the cloned repository directory."
    exit 1
fi

# Check if running on a supported system
echo "🔍 Checking system requirements..."

# Check if it's a ThinkPad
if [ ! -f /proc/acpi/ibm/fan ]; then
    echo "⚠️  Warning: ThinkPad fan control interface not detected (/proc/acpi/ibm/fan)"
    echo "This extension is designed for ThinkPad laptops with thinkpad_acpi module."
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi
fi

# Check GNOME Shell version
if command -v gnome-shell &> /dev/null; then
    GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "✓ GNOME Shell version: $GNOME_VERSION"
    
    # Check if version is supported (45+)
    if ! echo "$GNOME_VERSION" | awk '{exit !($1 >= 45)}'; then
        echo "⚠️  Warning: This extension is designed for GNOME Shell 45+."
        echo "Your version ($GNOME_VERSION) may not be fully supported."
        echo ""
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 1
        fi
    fi
else
    echo "⚠️  Warning: GNOME Shell not found. Are you running GNOME?"
fi

echo ""
echo "📁 Installing extension..."

# Create extensions directory if it doesn't exist
mkdir -p "$HOME/.local/share/gnome-shell/extensions"

# Remove existing installation if present
if [ -d "$EXTENSION_DIR" ]; then
    echo "🗑️  Removing existing installation..."
    rm -rf "$EXTENSION_DIR"
fi

# Copy extension files
echo "📋 Copying extension files..."
cp -r "$SOURCE_DIR" "$EXTENSION_DIR"

# Make setup script executable
chmod +x "$EXTENSION_DIR/setup.sh"

# Compile schemas
echo "🔧 Compiling GSettings schemas..."
if command -v glib-compile-schemas &> /dev/null; then
    glib-compile-schemas "$EXTENSION_DIR/schemas/"
    echo "✓ Schemas compiled successfully"
else
    echo "⚠️  Warning: glib-compile-schemas not found. Schemas may not work properly."
fi

echo ""
echo "✅ Extension installed successfully!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. 🔐 Configure sudo access (REQUIRED):"
echo "   cd '$EXTENSION_DIR'"
echo "   ./setup.sh"
echo ""
echo "2. 🔧 Configure ThinkPad ACPI module:"
echo "   echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf"
echo "   sudo modprobe -r thinkpad_acpi"
echo "   sudo modprobe thinkpad_acpi"
echo ""
echo "3. 🔄 Restart GNOME Shell:"
echo "   - On X11: Press Alt+F2, type 'r', press Enter"
echo "   - On Wayland: Log out and log back in"
echo ""
echo "4. ✅ Enable the extension:"
echo "   gnome-extensions enable $EXTENSION_UUID"
echo ""
echo "   Or use GNOME Extensions app/website:"
echo "   https://extensions.gnome.org/local/"
echo ""

# Offer to run setup script automatically
echo "🤖 Automatic Setup"
echo "=================="
read -p "Would you like to run the sudo setup script now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔐 Running sudo setup..."
    cd "$EXTENSION_DIR"
    ./setup.sh
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Sudo setup completed successfully!"
    else
        echo ""
        echo "❌ Sudo setup failed. You can run it manually later:"
        echo "   cd '$EXTENSION_DIR' && ./setup.sh"
    fi
fi

echo ""
read -p "Would you like to configure the ThinkPad ACPI module now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔧 Configuring ThinkPad ACPI module..."
    
    # Check if already configured
    if grep -q "thinkpad_acpi.*fan_control=1" /etc/modprobe.d/thinkpad_acpi.conf 2>/dev/null; then
        echo "✓ ThinkPad ACPI module already configured"
    else
        echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf
        echo "✓ Configuration file created"
    fi
    
    echo "🔄 Reloading thinkpad_acpi module..."
    sudo modprobe -r thinkpad_acpi 2>/dev/null || true
    sudo modprobe thinkpad_acpi
    
    if [ -f /proc/acpi/ibm/fan ]; then
        echo "✅ ThinkPad fan control is now available!"
        echo ""
        echo "Current fan status:"
        cat /proc/acpi/ibm/fan | head -3
    else
        echo "❌ Fan control interface still not available."
        echo "You may need to reboot or check if your ThinkPad supports fan control."
    fi
fi

echo ""
read -p "Would you like to enable the extension now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "✅ Enabling extension..."
    
    if command -v gnome-extensions &> /dev/null; then
        gnome-extensions enable "$EXTENSION_UUID"
        echo "✓ Extension enabled!"
        echo ""
        echo "🎉 Installation complete!"
        echo ""
        echo "Look for the fan icon in your top panel."
        echo "If you don't see it, you may need to restart GNOME Shell:"
        echo "- X11: Alt+F2 → type 'r' → Enter"
        echo "- Wayland: Log out and log back in"
    else
        echo "❌ gnome-extensions command not found."
        echo "Enable the extension manually using GNOME Extensions app or:"
        echo "https://extensions.gnome.org/local/"
    fi
else
    echo ""
    echo "🔧 Manual activation required:"
    echo "Run: gnome-extensions enable $EXTENSION_UUID"
    echo "Or use the GNOME Extensions app"
fi

echo ""
echo "📖 For troubleshooting and usage instructions, see:"
echo "   https://github.com/NoXei/Fan-Control-Slider/blob/main/README.md"
echo ""
echo "⚠️  Remember: Always monitor temperatures when using manual fan levels!"
echo ""
echo "🎉 Happy cooling! 🌪️"
