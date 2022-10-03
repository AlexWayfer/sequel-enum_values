# frozen_string_literal: true

require 'simplecov'

if ENV['CI']
	require 'simplecov-cobertura'
	SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

require 'sequel'
require 'sequel/extensions/migration'

require_relative '../lib/sequel/plugins/enum_values'

require 'pry-byebug'
