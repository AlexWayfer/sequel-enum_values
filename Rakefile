# frozen_string_literal: true

require 'rake/testtask'
Rake::TestTask.new(:spec) do |t|
	t.pattern = %w[spec/**/spec_helper.rb spec/**/*_spec.rb]
end

task default: :spec
