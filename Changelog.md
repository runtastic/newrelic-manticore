# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2021-05-17
- Require newrelic_rpm 8.x
- Dropped support for newrelic_rpm 6 and 7
- Removed deprecated NewRelic API methods
- Removed workaround for DatastoreSegment

## [1.2.0] - 2021-05-17
- Require newrelic_rpm > 6 and < 8

## [1.1.0] - 2020-08-27
### Added
- Record response status on external request span

### Changed
- Require ruby > 2.0.0

### Fixed
- Added manticore as dependency

## [1.0.1] - 2020-04-30
### Added
- Compatibility with agent versions ~> 6.10

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
