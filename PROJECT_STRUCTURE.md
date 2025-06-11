# Project Structure

```
Fan-Control-Slider/
├── README.md                          # Main project documentation
├── CHANGELOG.md                       # Version history and changes
├── CONTRIBUTING.md                    # Development and contribution guidelines
├── LICENSE                           # GPL-3.0 license
├── install.sh                        # Automated installation script
├── uninstall.sh                      # Clean removal script
├── test.sh                           # Installation verification script
└── thinkpad-fan-control@noxei.dev/   # Extension directory
    ├── extension.js                  # Main extension logic
    ├── metadata.json                 # Extension metadata and compatibility
    ├── prefs.js                      # Settings/preferences panel
    ├── setup.sh                      # Sudo configuration script
    ├── stylesheet.css                # Extension styling
    ├── icons/                        # Extension icons (if any)
    └── schemas/                      # GSettings schemas
        ├── gschemas.compiled         # Compiled schema file
        └── org.gnome.shell.extensions.thinkpad-fan-control.gschema.xml
```

## File Descriptions

### Root Level Scripts
- **install.sh**: Interactive installation with automatic setup options
- **uninstall.sh**: Complete removal with cleanup verification
- **test.sh**: Comprehensive installation and functionality testing

### Documentation
- **README.md**: User manual with safety guidelines and installation instructions
- **CHANGELOG.md**: Version history following semantic versioning
- **CONTRIBUTING.md**: Developer guidelines and safety requirements
- **LICENSE**: GPL-3.0 license with safety disclaimers

### Extension Files
- **extension.js**: Core functionality with safety-first fan control
- **metadata.json**: GNOME Shell compatibility and project metadata
- **prefs.js**: Settings interface for user preferences
- **setup.sh**: Secure sudo configuration for passwordless fan control
- **stylesheet.css**: UI styling for professional appearance

## Installation Flow

1. User clones repository
2. Runs `./install.sh` for guided setup
3. Script validates system requirements
4. Extension files copied to proper location
5. Sudo permissions configured securely
6. ThinkPad ACPI module enabled
7. Extension activated in GNOME Shell

## Safety Architecture

- **No dangerous modes exposed** in UI (disengaged detection only)
- **Emergency auto button** appears if system enters unsafe state
- **Temperature monitoring** with visual warnings
- **Validated commands** prevent malicious input
- **Graceful error handling** prevents system freezes

## Professional Standards

- Semantic versioning (v2.0.0)
- Professional domain UUID (@noxei.dev)
- Comprehensive documentation
- Automated testing and verification
- Clean installation/removal process
- GPL-3.0 licensing with safety disclaimers
