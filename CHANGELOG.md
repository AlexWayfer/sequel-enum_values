# Changelog

## Unreleased

## 2.0.0 (2026-02-19)

*   Rename internal instance variables.
    Avoid the conflict with [`static_cache` Sequel's plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/StaticCache.html)
*   Drop Ruby 2.3, 2.4, 2.5, 2.6, 2.7, 3.0 and 3.1 support.
*   Add Ruby 3.2, 3.3, 3.4 and 4.0 support.
*   Update `sequel` runtime dependency.
*   Make tests coverage 100%.
*   Improve version locks of dependencies.
*   Update development dependencies.
*   Resolve new RuboCop offenses.
*   Improve CI config.

## 1.2.0 (2018-02-01)

*   Add `caching` option for plugin.
    Cache enum values in plugin by default.
*   Add `predicate_methods` option.
    Supports `true`, `false`, `%i[]` or `Symbol`. Default is `false`.
*   Switch from Minitest (-Bacon) to RSpec.
*   Add documentation for public methods.

## 1.0.0 (2017-10-16)

*   Initial release.
