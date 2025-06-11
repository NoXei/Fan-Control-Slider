#!/bin/bash

# ThinkPad Fan Control Extension - Uninstall Script
# This script completely removes the GNOME Shell extension

set -e  # Exit on any error

EXTENSION_UUID="thinkpad-fan-control@noxei.dev"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

echo "🗑️  ThinkPad Fan Control Extension - Uninstall Script"
echo "===================================================="
echo ""

# Check if extension is installed
if [ ! -d "$EXTENSION_DIR" ]; then
    echo "❌ Extension not found at $EXTENSION_DIR"
    echo "It may already be uninstalled."
    exit 0
fi

echo "🔍 Found extension installation at:"
echo "   $EXTENSION_DIR"
echo ""

# Warn user about removal
echo "⚠️  This will completely remove the ThinkPad Fan Control extension."
echo "❗ Your fan will return to automatic control after removal."
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo ""
echo "🔄 Disabling extension..."

# Disable extension if it's enabled
if command -v gnome-extensions &> /dev/null; then
    if gnome-extensions list --enabled | grep -q "$EXTENSION_UUID"; then
        gnome-extensions disable "$EXTENSION_UUID"
        echo "✓ Extension disabled"
    else
        echo "✓ Extension was not enabled"
    fi
else
    echo "⚠️  gnome-extensions command not available, skipping disable step"
fi

echo ""
echo "🗑️  Removing extension files..."

# Remove extension directory
rm -rf "$EXTENSION_DIR"
echo "✓ Extension files removed"

echo ""
echo "🔐 Cleaning up sudo configuration..."

# Ask about removing sudo configuration
read -p "Remove sudo configuration for fan control? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "/etc/sudoers.d/thinkpad-fan-control" ]; then
        sudo rm -f "/etc/sudoers.d/thinkpad-fan-control"
        echo "✓ Sudo configuration removed"
    else
        echo "✓ No sudo configuration found"
    fi
else
    echo "⚠️  Keeping sudo configuration (can be removed manually later)"
    echo "   File: /etc/sudoers.d/thinkpad-fan-control"
fi

echo ""
echo "🔧 Resetting fan to auto mode..."

# Reset fan to auto mode before complete removal
if [ -f /proc/acpi/ibm/fan ]; then
    if sudo -n sh -c 'echo "level auto" > /proc/acpi/ibm/fan' 2>/dev/null; then
        echo "✓ Fan set to automatic control"
    else
        echo "⚠️  Could not reset fan to auto (may require password)"
        echo "   Run manually: sudo sh -c 'echo \"level auto\" > /proc/acpi/ibm/fan'"
    fi
else
    echo "⚠️  Fan control interface not available"
fi

echo ""
echo "🔄 Cleaning up GNOME Shell..."

# Ask about GNOME Shell restart
read -p "Restart GNOME Shell to complete removal? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔄 Restarting GNOME Shell..."
    
    # Check if running on X11 or Wayland
    if [ "$XDG_SESSION_TYPE" = "x11" ]; then
        echo "Detected X11 session - restarting GNOME Shell..."
        killall -HUP gnome-shell &
        echo "✓ GNOME Shell restart initiated"
    else
        echo "Detected Wayland session - you need to log out and back in"
        echo "   The extension will be fully removed after relogin"
    fi
else
    echo "⚠️  You may need to restart GNOME Shell manually:"
    echo "   - X11: Alt+F2 → type 'r' → Enter"
    echo "   - Wayland: Log out and log back in"
fi

echo ""
echo "✅ Uninstall completed!"
echo ""
echo "📝 Summary:"
echo "   ✓ Extension disabled and removed"
echo "   ✓ Fan reset to automatic control"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "   ✓ Sudo configuration removed"
else
    echo "   ⚠️  Sudo configuration kept"
fi
echo ""
echo "🎉 ThinkPad Fan Control extension has been uninstalled."
echo "Your system's thermal management is back to automatic control."
echo ""

# Optional: Offer to remove ThinkPad ACPI configuration
echo "🔧 Optional: ThinkPad ACPI Module Configuration"
echo "=============================================="
read -p "Remove fan_control=1 from thinkpad_acpi module config? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "/etc/modprobe.d/thinkpad_acpi.conf" ]; then
        echo ""
        echo "Current configuration:"
        cat /etc/modprobe.d/thinkpad_acpi.conf
        echo ""
        read -p "Remove this file? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo rm -f /etc/modprobe.d/thinkpad_acpi.conf
            echo "✓ ThinkPad ACPI configuration removed"
            echo ""
            echo "🔄 Module changes will take effect after reboot"
            echo "   or manual module reload with: sudo modprobe -r thinkpad_acpi && sudo modprobe thinkpad_acpi"
        fi
    else
        echo "✓ No ThinkPad ACPI configuration found"
    fi
else
    echo "⚠️  Keeping ThinkPad ACPI configuration"
    echo "   Fan control will remain available for other tools"
fi

echo ""
echo "🎉 All done! Thank you for using ThinkPad Fan Control! 🌪️"
