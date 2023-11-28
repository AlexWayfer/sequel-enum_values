# Sequel enum_values plugin

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/sequel-enum_values?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/sequel-enum_values)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/sequel-enum_values/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/sequel-enum_values)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/sequel-enum_values.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/sequel-enum_values)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/sequel-enum_values?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/sequel-enum_values)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/sequel-enum_values.svg?branch=main)](https://inch-ci.org/github/AlexWayfer/sequel-enum_values)
[![Gem](https://img.shields.io/gem/v/sequel-enum_values.svg?style=flat-square)](https://rubygems.org/gems/sequel-enum_values)
[![License](https://img.shields.io/github/license/AlexWayfer/sequel-enum_values.svg?style=flat-square)](LICENSE.txt)

A Sequel plugin that provides `enum_values(field)` method to your models.

## Installation

### Bundler

Add this line to your project's Gemfile:

```ruby
gem 'sequel-enum_values', require: 'sequel/plugins/enum_values'
```

And then execute:

```
$ bundle
```

### Manually

Install this gem as:

```
$ gem install sequel-enum_values
```

And then require it in your project:

```ruby
require 'sequel/plugins/enum_values'
```

## Usage

If you have database schema like this:

```ruby
create_enum :item_type, %w[first second third]
create_enum :item_status, %w[created selected canceled]

create_table :items do
  primary_key :id
  column :type, :item_type
  column :status, :item_status
end
```

Then you can use it like this:

```ruby
class Item < Sequel::Model
  plugin :enum_values
end

Item.enum_values(:type) # => ["first", "second", "third"]
Item.enum_values(:status) # => ["created", "selected", "canceled"]
```

### Caching

Plugin caches enum values for each field by default.

But you can disable it:

```ruby
Item.plugin :enum_values, caching: false
```

### Predicate methods

Plugin can define instance methods for all enum values:

```ruby
Item.plugin :enum_values, predicate_methods: true # default is `false`

item = Item.new(type: 'first', status: 'created')

item.first? # => true
item.second? # => false

item.created? # => true
item.selected? # => false
```

Or just for specific fields:

```ruby
Item.plugin :enum_values, predicate_methods: %i[status]
# or just `:status` for single value

item = Item.new(type: 'first', status: 'created')

item.first? # => NoMethodError

item.created? # => true
item.selected? # => false
```

### Filter methods

Plugin can define dataset methods for all enum values:

```ruby
Item.plugin :enum_values, filter_methods: true # default is `false`

Item.dataset.one # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"type\" = 'one')">
Item.dataset.another # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"type\" = 'another')">

Item.dataset.created # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"status\" = 'created')">
Item.dataset.selected # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"status\" = 'selected')">
```

Or just for specific fields:

```ruby
Item.plugin :enum_values, filter_methods: %i[status]
# or just `:status` for single value

item = Item.new(type: 'one', status: 'created')

Item.dataset.one # => NoMethodError

Item.dataset.created # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"status\" = 'created')">
Item.dataset.selected # => #<Sequel::Dataset: "SELECT * FROM \"items\" WHERE (\"status\" = 'selected')">
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/sequel-enum_values).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
