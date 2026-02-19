# frozen_string_literal: true

include :bundler, static: true

require 'gem_toys'
expand GemToys::Template,
	version_file_path: 'lib/sequel/plugins/enum_values/version.rb'

alias_tool :g, :gem
