# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2019-03-12
### Changed
- Update newrelic agent dependency to major version 6.
- Replace deprecated calls to internal agent API.

## [0.1.2] - 2018-10-11
### Fixed
Detection whether manticore is used inside a database segment was not reliable and is now more robust

## [0.1.1] - 2018-10-09
### Fixed
- Time spent inside Manticore requests inside database calls where not included in the exclusive time stats of the database request.
- Fixed instrumentation when using manticore with faraday adapter.

## [0.1.0] - 2018-10-09
### Added
- Basic manticore instrumentation.
