# frozen_string_literal: true

require_relative 'lib/sequel/plugins/enum_values/version'

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

	s.required_ruby_version = '>= 2.4.0'

	s.add_runtime_dependency 'sequel', '>= 4.1.0', '<= 6'

	s.add_development_dependency 'codecov', '~> 0.1.15'
	s.add_development_dependency 'pry-byebug', '~> 3.5'
	s.add_development_dependency 'rack-test', '~> 1.1'
	s.add_development_dependency 'rake', '~> 13.0'
	s.add_development_dependency 'rspec', '~> 3.7'
	s.add_development_dependency 'rubocop', '~> 0.82.0'
	s.add_development_dependency 'rubocop-performance', '~> 1.5'
	s.add_development_dependency 'rubocop-rspec', '~> 1.38'
	s.add_development_dependency 'simplecov', '~> 0.18.1'

	s.files = Dir[File.join('lib', '**', '*')]
end
