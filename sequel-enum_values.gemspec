# frozen_string_literal: true

require_relative 'lib/sequel/plugins/enum_values/version'

Gem::Specification.new do |spec|
	spec.name        = 'sequel-enum_values'
	spec.version     = Sequel::Plugins::EnumValues::VERSION

	spec.summary     = <<~TEXT
		Sequel plugin that provides method for getting `pg_enum` values
	TEXT

	spec.description = <<~TEXT
		Now your `Sequel::Model` classes has method for getting `pg_enum` values from DataBase by field name.
	TEXT

	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']
	spec.license     = 'MIT'

	source_code_uri = 'https://github.com/AlexWayfer/sequel-enum_values'

	spec.homepage = source_code_uri

	spec.metadata['source_code_uri'] = source_code_uri

	spec.metadata['homepage_uri'] = spec.homepage

	spec.metadata['changelog_uri'] =
		'https://github.com/AlexWayfer/sequel-enum_values/blob/master/CHANGELOG.md'

	spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']

	spec.required_ruby_version = '>= 2.5', '< 4'

	spec.add_runtime_dependency 'sequel', '>= 4.1.0', '<= 6'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.8.0'
	spec.add_development_dependency 'toys', '~> 0.12.0'

	spec.add_development_dependency 'codecov', '~> 0.5.0'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.21.2'

	spec.add_development_dependency 'rubocop', '~> 1.3'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
