# Sequel enum_values plugin

![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/sequel-enum_values?style=flat-square)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/sequel-enum_values/master.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/sequel-enum_values)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/sequel-enum_values.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/sequel-enum_values)
![Depfu](https://img.shields.io/depfu/AlexWayfer/sequel-enum_values?style=flat-square)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/sequel-enum_values.svg?branch=master)](https://inch-ci.org/github/AlexWayfer/sequel-enum_values)
[![Gem](https://img.shields.io/gem/v/sequel-enum_values.svg?style=flat-square)](https://rubygems.org/gems/sequel-enum_values)
[![license](https://img.shields.io/github/license/AlexWayfer/sequel-enum_values.svg?style=flat-square)](https://github.com/AlexWayfer/sequel-enum_values/blob/master/LICENSE.txt)

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
````

Or just for specific fields:

```ruby
Item.plugin :enum_values, predicate_methods: %i[status]
# or just `:status` for single value

item = Item.new(type: 'first', status: 'created')

item.first? # => NoMethodError

item.created? # => true
item.selected? # => false
````

## Contributing

1.  Fork it
2.  Create your feature branch
3.  Commit your changes
4.  Push to the branch
5.  Create new Pull Request
