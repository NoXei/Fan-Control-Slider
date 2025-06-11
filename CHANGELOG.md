# Changelog

All notable changes to the ThinkPad Fan Control Extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive installation script (`install.sh`)
- Automated testing script (`test.sh`) 
- Clean uninstallation script (`uninstall.sh`)
- Detailed documentation and safety guidelines
- Contributing guidelines
- Better error handling and user feedback

### Changed
- Improved README with clear installation instructions
- Enhanced safety warnings and documentation
- Better installation verification process

### Security
- Updated sudo configuration for better security
- More restrictive permission handling

## [2.0.0] - 2025-06-11

### Added
- Comprehensive installation script (`install.sh`)
- Automated testing script (`test.sh`) 
- Clean uninstallation script (`uninstall.sh`)
- Detailed documentation and safety guidelines
- Contributing guidelines
- Better error handling and user feedback

### Changed
- Improved README with clear installation instructions
- Enhanced safety warnings and documentation
- Better installation verification process
- Updated extension UUID to use professional domain (@noxei.dev)
- Enhanced metadata with proper description and repository URL

### Security
- Updated sudo configuration for better security
- More restrictive permission handling

## [1.0.0] - 2025-06-01

### Added
- Slider-based fan control interface
- Real-time fan speed (RPM) monitoring
- CPU temperature display option
- Safety-first design preventing dangerous disengaged mode access
- Emergency auto mode button for dangerous states
- Visual feedback with different icons for fan states
- Settings panel with display and behavior options
- Comprehensive safety features and warnings
- Support for GNOME Shell 45+
- Passwordless sudo configuration for safe operation

### Safety Features
- Smart level mapping (Auto, Levels 0-7, Max Safe)
- Disengaged mode detection and warnings
- No direct access to dangerous thermal protection disable
- Emergency recovery options
- Temperature monitoring and guidelines

### Security
- Secure sudo implementation (no pkexec to prevent freezes)
- Command validation and sanitization
- Setup script for safe configuration
- Minimal privilege requirements

### Documentation
- Comprehensive README with safety guidelines
- Installation and troubleshooting instructions
- Temperature safety guidelines
- Usage examples and best practices

### Technical Details
- GSettings integration for preferences
- Real-time status updates every 5 seconds
- Robust error handling
- Clean extension lifecycle management
- Proper GNOME Shell integration

---

## Development History

This extension evolved through several phases prioritizing safety:

1. **Initial Development**: Basic fan control functionality
2. **Safety Crisis Resolution**: Fixed dangerous pkexec system freezes  
3. **UI Enhancement**: Implemented smooth slider interface
4. **Safety Hardening**: Removed dangerous disengaged mode from UI
5. **Current Version**: Comprehensive safety features with emergency controls

## Safety Philosophy

Every change prioritizes user safety:
- Hardware protection over convenience features
- Clear warnings over hidden dangers  
- Emergency recovery over complex controls
- Thermal protection preservation
- System stability assurance

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.
