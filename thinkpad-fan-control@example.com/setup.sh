#!/bin/bash

# ThinkPad Fan Control Setup Script
# This script sets up passwordless sudo access for fan control

echo "ThinkPad Fan Control Setup"
echo "=========================="
echo ""
echo "This will configure your system to allow the ThinkPad Fan Control extension"
echo "to change fan modes without prompting for a password."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root."
    echo "Run it as your regular user, and it will prompt for sudo when needed."
    exit 1
fi

# Check if ThinkPad fan control is available
if [ ! -f /proc/acpi/ibm/fan ]; then
    echo "ERROR: ThinkPad fan control not available on this system."
    echo "Make sure you're running on a ThinkPad with thinkpad_acpi module loaded."
    exit 1
fi

echo "Current fan status:"
cat /proc/acpi/ibm/fan | head -3
echo ""

# Create sudoers entry - more secure and properly quoted
SUDOERS_ENTRY="%sudo ALL=(ALL) NOPASSWD: /bin/sh -c \"echo * > /proc/acpi/ibm/fan\""
SUDOERS_FILE="/etc/sudoers.d/thinkpad-fan-control"

echo "Creating sudoers configuration..."

# Create the sudoers file
echo "$SUDOERS_ENTRY" | sudo tee "$SUDOERS_FILE" > /dev/null

if [ $? -eq 0 ]; then
    echo "✓ Sudoers configuration created successfully"
    
    # Test the configuration
    echo "Testing fan control access..."
    
    # Try to read current state
    CURRENT_MODE=$(cat /proc/acpi/ibm/fan | grep "level:" | awk '{print $2}')
    echo "Current fan mode: $CURRENT_MODE"
    
    # Try to set it to the same mode (should be safe)
    sudo -n sh -c "echo 'level $CURRENT_MODE' > /proc/acpi/ibm/fan" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Fan control access working correctly"
        echo ""
        echo "Setup complete! You can now:"
        echo "1. Enable the ThinkPad Fan Control extension"
        echo "2. Use the fan icon in your top panel to control fan modes"
        echo ""
        echo "Available modes:"
        echo "- Auto: Let the system control fan speed automatically"
        echo "- Full Speed: Run fan at maximum speed"
        echo "- Disengaged: Turn off automatic fan control (use with caution!)"
    else
        echo "⚠ Warning: Fan control access test failed"
        echo "You may need to log out and log back in for changes to take effect"
    fi
else
    echo "✗ Failed to create sudoers configuration"
    echo "Please check your sudo privileges"
    exit 1
fi

echo ""
echo "IMPORTANT SAFETY NOTES:"
echo "- Use 'Disengaged' mode with extreme caution"
echo "- Monitor temperatures when using manual fan control"
echo "- The system may override fan settings for thermal protection"
