# frozen_string_literal: true

source 'https://rubygems.org/'

gemspec

group :development do
	gem 'pry-byebug', '~> 3.9'

	gem 'gem_toys', '~> 1.0'
	gem 'toys', '~> 0.19.0'
end

group :development, :audit do
	gem 'bundler-audit', '~> 0.9.0'
end

group :test do
	gem 'rspec', '~> 3.9'
	gem 'simplecov', '~> 0.22.0'
	gem 'simplecov-cobertura', '~> 3.0'
end

group :lint do
	gem 'rubocop', '~> 1.81.0'
	gem 'rubocop-performance', '~> 1.26.0'
	gem 'rubocop-rspec', '~> 3.7.0'
end
