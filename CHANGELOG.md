# Changelog

## [Unreleased]

### Added

- Responsive design with mobile adaptations
- Trivial support for rtl direction
- Expand info box:
  - no full mobile support
  - privacy notice
  - version info
  
### Changed

- Minor style change

## [0.4.0] 2022-10-03

### Added

- Info button and popup
- Transitions between _working_ and _done_ UIs

### Changed

- Some component structure change
- Use padding instead of grid to position the main UI.
- Some restyling

## [0.3.0] 2022-09-14

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
- The style sheet is now built and bundled from `src` as well

## [0.1.0] 2022-08-25

Minimal ugly working version.
