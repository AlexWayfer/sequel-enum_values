# frozen_string_literal: true

require_relative 'lib/sequel/plugins/enum_values'

Gem::Specification.new do |s|
	s.name        = 'sequel-enum_values'
	s.version     = Sequel::Plugins::EnumValues::VERSION

	s.summary     = 'Sequel plugin that provides method' \
	                ' for getting `pg_enum` values'
	s.description = 'Now your `Sequel::Model` classes has method' \
	                ' for getting `pg_enum` values from DataBase by field name.'

	s.authors     = ['Alexander Popov']
	s.email       = ['alex.wayfer@gmail.com']
	s.homepage    = 'https://github.com/AlexWayfer/sequel-enum_values'
	s.license     = 'MIT'

	s.add_runtime_dependency 'sequel'

	s.add_development_dependency 'rubocop', '~> 0.50'
	s.add_development_dependency 'rake', '~> 12'
	s.add_development_dependency 'minitest-bacon', '~> 1'
	s.add_development_dependency 'minitest-reporters', '~> 1'
	s.add_development_dependency 'rack-test', '~> 0'
	s.add_development_dependency 'simplecov', '~> 0'
	s.add_development_dependency 'codecov', '~> 0'
	s.add_development_dependency 'pry', '~> 0'
	s.add_development_dependency 'pry-byebug', '~> 3.5'

	s.files = Dir[File.join('lib', '**', '*')]
end
