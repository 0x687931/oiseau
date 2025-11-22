# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-11-22

### Added
- Comprehensive BATS test suite for interactive UI components (#69, #71)
- Multi-line progress bar support with relative cursor positioning (#58)
- VHS demo recordings for all widgets
- Enhanced zsh compatibility mode (#60)
- Accessibility palettes (colorblind, high-contrast) with WCAG contrast ratios
- Test infrastructure extensibility architecture (#73)
- Comprehensive vertical alignment validation and tests
- Emoji alignment test demonstrating resolved issues (#70)
- Auto-reset functionality for multiple progress bar groups
- Race condition mitigations for multiline progress bars

### Fixed
- Vertical alignment in BATS tests to respect function contracts (#87, #72)
- ASCII-only user input policy to prevent alignment issues (#86)
- Gallery.sh to properly strip only emoji/CJK characters, not ASCII letters
- Terminal-agnostic box alignment
- Box alignment in README examples

### Changed
- Updated README to 1980s technical manual aesthetic
- Condensed README with improved accessibility documentation
- Progress bar demos now use multi-line progress implementation
- VHS demos redesigned with side-by-side mode comparisons
- Reorganized demo files for consistent naming convention

## [1.0.0] - 2024

Initial stable release.

### Features
- 32 terminal UI widgets
- Pure bash implementation with zero dependencies
- Graceful degradation (UTF-8+256color → ASCII+256color → ASCII monochrome)
- Three display modes: rich, color, plain
- Automatic terminal capability detection
- POSIX utility compatibility
- Security features with input sanitization
- Comprehensive test suite
- Interactive gallery demo
- TUI mode support

[1.1.0]: https://github.com/0x687931/oiseau/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/0x687931/oiseau/releases/tag/v1.0.0
