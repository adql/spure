# Changelog

## [Unreleased]

### Added

- Hide UI elements (currently only one) while writing and show them again on mouse move.
- Footer

### Changed

- Use CSS instead of `onMouseDown` event to prevent selection or caret control with the mouse.
- Prevent accidentally deleting the text by selecting it with `ctrl-a` and typing.

## [0.2.0] 2022-09-06

### Added

- Allow deletion in current word for typo corrections.
- CSS reset ([modern-normalize](https://github.com/sindresorhus/modern-normalize))

### Changed

- A fairly decent look and feel
- Minification + minor changes in build scripts.
- The style sheet is now build and bundled from `src` as well

## [0.1.0] 2022-08-25

Minimal ugly working version.
