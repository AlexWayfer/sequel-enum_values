# Changelog

## Unreleased

*   Rename internal instance variables.
    Avoid the conflict with [`static_cache` Sequel's plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/StaticCache.html)
*   Drop support for Ruby 2.3.
*   Improve version locks of dependencies.
*   Make tests coverage 100%.
*   Switch from Travis CI to Cirrus CI.
*   Update RuboCop, add `rubocop-performance` and `rubocop-rspec`, resolve offenses.

## 1.2.0 (2018-02-01)

*   Add `caching` option for plugin.
    Cache enum values in plugin by default.
*   Add `predicate_methods` option.
    Supports `true`, `false`, `%i[]` or `Symbol`. Default is `false`.
*   Switch from Minitest (-Bacon) to RSpec.
*   Add documentation for public methods.

## 1.0.0 (2017-10-16)

*   Initial release.
