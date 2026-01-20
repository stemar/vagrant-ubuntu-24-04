# Changelog

## 1.0.2 - 2026-01-19

### Added

- Added Ruby.

### Changed

- Changed Adminer theme.

## 1.0.1 - 2026-01-16

### Changed

- Updated YAML array format in `settings.yaml`.
    - Updated `:php_error_reporting` value.
- Updated `Vagrantfile` by adding local variables.
    - Modernized path in the `YAML.load_file()` call.
- Replaced `FORWARDED_PORT_80` variable with `HOST_HTTP_PORT` in 3 files.
    - Updated `provision.sh`, `adminer.conf`, `virtualhost.conf` with new variable name.
- Modified the version section of `provision.sh` for the section title and the Apache version output.
- Updated the last section of `README.md`.

## 1.0.0 - 2025-10-05

_First release_
