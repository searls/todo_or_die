# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2022-06-27

- Add `warn_by` option [#14](https://github.com/searls/todo_or_die/pull/14)

## [0.0.3] - 2019-11-26
### Added
- Boolean-returning conditionals or callables (Proc, Block, Lambda) can be passed to the
new `if` argument. `if` can be used instead of or in conjunction with the `by` argument
to die on a specific date OR when a specific condition becomes true.

### Changed
- Date strings can now be parsed parsed internally without calling `Time` or `Date`
classes explicitely.

## [0.0.2] - 2019-02-15
### Changed
- Exclude this gem's backtrace location from exceptions thrown to make it easier to find
TODOs.

## [0.0.1] - 2019-01-01

[Unreleased]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.3...HEAD
[0.0.3]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/olivierlacan/keep-a-changelog/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/olivierlacan/keep-a-changelog/releases/tag/v0.0.1
