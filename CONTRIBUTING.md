# Contributing to ThinkPad Fan Control Extension

Thank you for your interest in contributing to this project! 🎉

## 🛠️ Development Setup

### Prerequisites
- ThinkPad laptop with fan control support
- GNOME Shell 45+
- Git
- Basic knowledge of JavaScript/GJS

### Setting Up Development Environment

1. **Fork and clone the repository**:
```bash
git clone https://github.com/NoXei/Fan-Control-Slider.git
cd Fan-Control-Slider
```

2. **Install the extension in development mode**:
```bash
./install.sh
```

3. **Enable development tools**:
```bash
# Enable extension logging
export G_MESSAGES_DEBUG=all

# Watch extension logs
journalctl --user -f | grep thinkpad
```

## 🐛 Bug Reports

When reporting bugs, please include:

- **System Information**:
  - ThinkPad model
  - GNOME Shell version
  - Linux distribution
  - Extension version

- **Steps to Reproduce**: Clear steps to reproduce the issue

- **Expected vs Actual Behavior**: What should happen vs what actually happens

- **Logs**: Relevant output from:
  ```bash
  journalctl --user -f | grep thinkpad
  ```

- **Fan Status**: Output of:
  ```bash
  cat /proc/acpi/ibm/fan
  ```

## 🚀 Feature Requests

Before submitting a feature request:

1. Check existing issues to avoid duplicates
2. Consider if the feature aligns with the project's safety-first philosophy
3. Provide clear use cases and benefits

## 🔧 Pull Requests

### Before Submitting

1. **Test thoroughly** on your ThinkPad
2. **Follow safety guidelines** - never compromise thermal protection
3. **Update documentation** if needed
4. **Test the installation scripts**:
   ```bash
   ./test.sh
   ```

### Code Style

- Use consistent indentation (4 spaces for JavaScript)
- Follow existing naming conventions
- Add comments for complex logic
- Prioritize safety over features

### Safety Requirements

Any changes must:
- ✅ Never disable thermal protection by default
- ✅ Provide clear warnings for dangerous operations
- ✅ Maintain emergency recovery options
- ✅ Validate user inputs

## 🛡️ Security Guidelines

- **Sudo Usage**: Minimize and validate all sudo commands
- **Input Validation**: Sanitize all user inputs
- **Error Handling**: Gracefully handle all error conditions
- **Permissions**: Use least privilege principle

## 📋 Testing Checklist

Before submitting:

- [ ] Extension installs cleanly with `./install.sh`
- [ ] All tests pass with `./test.sh`
- [ ] Extension uninstalls cleanly with `./uninstall.sh`
- [ ] Fan returns to auto mode safely
- [ ] No system freezes or crashes
- [ ] Works on both X11 and Wayland
- [ ] Temperature monitoring functions correctly
- [ ] Settings are preserved across restarts

## 🏷️ Release Process

For maintainers:

1. Update version in `metadata.json`
2. Update `CHANGELOG.md`
3. Test on multiple GNOME Shell versions
4. Create release notes
5. Tag release

## 📝 Documentation

When adding features:

- Update `README.md` if user-facing
- Add inline code documentation
- Update safety warnings if applicable
- Consider adding examples

## 🤝 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Remember this project controls hardware - safety is paramount
- Help others learn and grow

## 💡 Ideas for Contributions

- **Translations**: Internationalization support
- **UI Improvements**: Better visual feedback
- **Compatibility**: Support for more ThinkPad models
- **Safety Features**: Enhanced temperature monitoring
- **Documentation**: Better user guides
- **Testing**: Automated testing infrastructure

## 🔗 Resources

- [GNOME Shell Extension Development](https://gjs.guide/)
- [ThinkPad ACPI Documentation](https://www.kernel.org/doc/html/latest/admin-guide/laptops/thinkpad-acpi.html)
- [GJS API Documentation](https://gjs-docs.gnome.org/)

## ❓ Questions?

- Open an issue for questions
- Check existing issues and discussions
- Read the troubleshooting section in README.md

Thank you for contributing to safer ThinkPad fan control! 🌪️
