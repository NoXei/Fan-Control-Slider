#!/bin/bash

# ThinkPad Fan Control Extension - Test Script
# This script verifies that the extension is properly installed and configured

EXTENSION_UUID="thinkpad-fan-control@example.com"
EXTENSION_DIR="$HOME/.local/share/gnome-shell/extensions/$EXTENSION_UUID"

echo "🔍 ThinkPad Fan Control Extension - Installation Test"
echo "===================================================="
echo ""

# Test 1: Check if extension directory exists
echo "1. 📁 Checking extension installation..."
if [ -d "$EXTENSION_DIR" ]; then
    echo "   ✅ Extension directory found: $EXTENSION_DIR"
else
    echo "   ❌ Extension directory not found: $EXTENSION_DIR"
    echo "   Run: ./install.sh"
    exit 1
fi

# Test 2: Check essential files
echo ""
echo "2. 📋 Checking extension files..."
required_files=("extension.js" "metadata.json" "prefs.js" "setup.sh" "stylesheet.css")
missing_files=()

for file in "${required_files[@]}"; do
    if [ -f "$EXTENSION_DIR/$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file (missing)"
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "   ❌ Missing files detected. Reinstall recommended."
    exit 1
fi

# Test 3: Check schemas
echo ""
echo "3. 🔧 Checking GSettings schemas..."
if [ -f "$EXTENSION_DIR/schemas/gschemas.compiled" ]; then
    echo "   ✅ Compiled schemas found"
else
    echo "   ❌ Compiled schemas missing"
    echo "   Run: glib-compile-schemas $EXTENSION_DIR/schemas/"
fi

# Test 4: Check if extension is enabled
echo ""
echo "4. 🔄 Checking extension status..."
if command -v gnome-extensions &> /dev/null; then
    if gnome-extensions list --enabled | grep -q "$EXTENSION_UUID"; then
        echo "   ✅ Extension is enabled"
    else
        echo "   ⚠️  Extension is installed but not enabled"
        echo "   Run: gnome-extensions enable $EXTENSION_UUID"
    fi
else
    echo "   ⚠️  gnome-extensions command not available"
fi

# Test 5: Check ThinkPad fan control interface
echo ""
echo "5. 🌪️  Checking ThinkPad fan control..."
if [ -f /proc/acpi/ibm/fan ]; then
    echo "   ✅ Fan control interface available: /proc/acpi/ibm/fan"
    echo ""
    echo "   Current fan status:"
    cat /proc/acpi/ibm/fan | head -3 | sed 's/^/      /'
else
    echo "   ❌ Fan control interface not available: /proc/acpi/ibm/fan"
    echo "   This system may not be a ThinkPad or thinkpad_acpi module is not loaded"
    echo "   Try: sudo modprobe thinkpad_acpi fan_control=1"
fi

# Test 6: Check sudo configuration
echo ""
echo "6. 🔐 Checking sudo configuration..."
if [ -f "/etc/sudoers.d/thinkpad-fan-control" ]; then
    echo "   ✅ Sudo configuration file exists"
    
    # Test if sudo works without password
    if sudo -n sh -c 'echo "test" > /dev/null' 2>/dev/null; then
        echo "   ✅ Passwordless sudo working"
    else
        echo "   ⚠️  Sudo configuration exists but may need user to be in sudo group"
        echo "   Run: ./setup.sh"
    fi
else
    echo "   ❌ Sudo configuration missing"
    echo "   Run: $EXTENSION_DIR/setup.sh"
fi

# Test 7: Check thinkpad_acpi module configuration
echo ""
echo "7. 🔧 Checking thinkpad_acpi module..."
if lsmod | grep -q thinkpad_acpi; then
    echo "   ✅ thinkpad_acpi module is loaded"
    
    if [ -f "/etc/modprobe.d/thinkpad_acpi.conf" ]; then
        echo "   ✅ Module configuration file exists"
        if grep -q "fan_control=1" /etc/modprobe.d/thinkpad_acpi.conf; then
            echo "   ✅ Fan control enabled in configuration"
        else
            echo "   ⚠️  Fan control not enabled in configuration"
            echo "   Run: echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf"
        fi
    else
        echo "   ⚠️  Module configuration file missing"
        echo "   Run: echo 'options thinkpad_acpi fan_control=1' | sudo tee /etc/modprobe.d/thinkpad_acpi.conf"
    fi
else
    echo "   ❌ thinkpad_acpi module not loaded"
    echo "   Run: sudo modprobe thinkpad_acpi fan_control=1"
fi

# Test 8: Check GNOME Shell version
echo ""
echo "8. 🖥️  Checking GNOME Shell compatibility..."
if command -v gnome-shell &> /dev/null; then
    GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "   ✅ GNOME Shell version: $GNOME_VERSION"
    
    if echo "$GNOME_VERSION" | awk '{exit !($1 >= 45)}'; then
        echo "   ✅ Version is supported (45+)"
    else
        echo "   ⚠️  Version may not be fully supported (requires 45+)"
    fi
else
    echo "   ❌ GNOME Shell not found"
fi

echo ""
echo "📊 Test Summary"
echo "==============="

# Count issues
issues=0

# Extension files
if [ ! -d "$EXTENSION_DIR" ] || [ ${#missing_files[@]} -gt 0 ]; then
    echo "❌ Extension installation issues"
    ((issues++))
else
    echo "✅ Extension files"
fi

# Fan control
if [ ! -f /proc/acpi/ibm/fan ]; then
    echo "❌ ThinkPad fan control not available"
    ((issues++))
else
    echo "✅ ThinkPad fan control"
fi

# Sudo configuration
if [ ! -f "/etc/sudoers.d/thinkpad-fan-control" ]; then
    echo "❌ Sudo configuration missing"
    ((issues++))
else
    echo "✅ Sudo configuration"
fi

echo ""
if [ $issues -eq 0 ]; then
    echo "🎉 All tests passed! The extension should work correctly."
    echo ""
    echo "💡 If you don't see the extension in your panel:"
    echo "   - Restart GNOME Shell (Alt+F2 → 'r' on X11, or logout/login on Wayland)"
    echo "   - Check: gnome-extensions list --enabled | grep thinkpad"
else
    echo "⚠️  $issues issue(s) found. Please resolve them before using the extension."
    echo ""
    echo "🔧 Quick fixes:"
    echo "   - Run: ./install.sh (for installation issues)"
    echo "   - Run: $EXTENSION_DIR/setup.sh (for sudo issues)"
fi

echo ""
