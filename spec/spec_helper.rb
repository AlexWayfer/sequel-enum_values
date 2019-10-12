# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

if ENV['CODECOV']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'sequel'
require 'sequel/extensions/migration'

require_relative '../lib/sequel/plugins/enum_values'

require 'pry-byebug'
