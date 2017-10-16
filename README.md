# Sequel enum_values plugin

A Sequel plugin that provides `enum_values(field)` method to your models.

## Status

[![Gem Version](https://badge.fury.io/rb/sequel-enum_values.svg)](https://badge.fury.io/rb/sequel-enum_values)
[![Build Status](https://travis-ci.org/AlexWayfer/sequel-enum_values.svg?branch=master)](https://travis-ci.org/AlexWayfer/sequel-enum_values)
[![codecov](https://codecov.io/gh/AlexWayfer/sequel-enum_values/branch/master/graph/badge.svg)](https://codecov.io/gh/AlexWayfer/sequel-enum_values)
[![Maintainability](https://api.codeclimate.com/v1/badges/67143521dcfcf854b40f/maintainability)](https://codeclimate.com/github/AlexWayfer/sequel-enum_values/maintainability)
[![Dependency Status](https://gemnasium.com/badges/github.com/AlexWayfer/sequel-enum_values.svg)](https://gemnasium.com/github.com/AlexWayfer/sequel-enum_values)

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

## Contributing

1.  Fork it
2.  Create your feature branch
3.  Commit your changes
4.  Push to the branch
5.  Create new Pull Request
