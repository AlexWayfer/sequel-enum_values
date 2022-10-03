# frozen_string_literal: true

require 'simplecov'

if ENV['CI']
	require 'simplecov-cobertura'
	SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

puts <<~DEBUG
	TEST_VARIABLE == 'the-value-of-encrypted-variable' is #{ENV['TEST_VARIABLE'] == 'the-value-of-encrypted-variable'}
DEBUG

require 'sequel'
require 'sequel/extensions/migration'

require_relative '../lib/sequel/plugins/enum_values'

require 'pry-byebug'
