# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_TOKEN']
	require 'codecov'
	SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

puts <<~DEBUG
	TEST_VARIABLE == 'the-value-of-encrypted-variable' is #{ENV['TEST_VARIABLE'] == 'the-value-of-encrypted-variable'}
DEBUG

require 'sequel'
require 'sequel/extensions/migration'

require_relative '../lib/sequel/plugins/enum_values'

require 'pry-byebug'
