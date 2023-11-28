# frozen_string_literal: true

require_relative 'enum_values/version'

module Sequel
	module Plugins
		## Plugin for getting enum values from PostgreSQL by field name
		module EnumValues
			## Initialize model state for this plugin
			## @param model [Sequel::Model] model for which plugin applying
			## @param _options [Hash] options (don't affect anything in this moment)
			def self.apply(model, _options = {})
				model.instance_exec do
					@enum_values_cache = {}
					@enum_values_caching = true
				end
			end

			## Configure model for this plugin
			## @param model [Sequel::Model] model in which plugin enabled
			## @param options [Hash] options for plugin
			## @option options [Boolean] caching (true) cache enum values
			## @option options [Boolean, Symbol, Array<Symbol>]
			##   predicate_methods (false)
			##   enum fields for which predicate methods will be defined
			## @option options [Boolean, Symbol, Array<Symbol>]
			##   filter_methods (false)
			##   enum fields for which dataset filter methods will be defined
			## @example Disable caching
			##   Item.plugin :enum_values, caching: false
			## @example Define predicate methods for all enum fields
			##   Item.plugin :enum_values, predicate_methods: true
			## @example Define predicate methods for specific enum fields
			##   Item.plugin :enum_values, predicate_methods: %[status type]
			## @example Define predicate methods for specific enum field
			##   Item.plugin :enum_values, predicate_methods: :status
			## @example Define filter methods for all enum fields
			##   Item.plugin :enum_values, filter_methods: true
			## @example Define filter methods for specific enum field
			##   Item.plugin :enum_values, filter_methods: :status
			## @example Define filter methods for specific enum fields
			##   Item.plugin :enum_values, filter_methods: %[status type]
			def self.configure(model, options = {})
				model.instance_exec do
					@enum_values_options = options

					process_enum_values_options
				end
			end

			## Module for class methods
			module ClassMethods
				## Get enum values for specific field
				## @param field [Symbol] name of enum field
				## @return [Array<String>] values of enum
				## @example Get enum values for `status` field of `Item` model
				##   Item.enum_values(:status)
				def enum_values(field)
					if @enum_values_caching && (cached_values = @enum_values_cache[field])
						return cached_values
					end

					field_schema = all_enum_fields[field]
					raise_field_nonexistent(field) if field_schema.nil?

					enum_values = field_schema[:enum_values]
					@enum_values_cache[field] = enum_values if @enum_values_caching
					enum_values
				end

				private

				def process_enum_values_options
					@enum_values_caching =
						@enum_values_options.fetch(:caching, @enum_values_caching)

					process_enum_values_option(:filter_methods) do |field, value|
						dataset.methods.include?(value.to_sym) &&
							warn("WARNING: Redefining method #{value}")

						dataset_module { where value, field => value }
					end

					process_enum_values_option(:predicate_methods) do |field, value|
						define_method("#{value}?", -> { public_send(field) == value })
					end
				end

				def process_enum_values_option(key)
					return unless (option = @enum_values_options[key])

					enum_fields = all_enum_fields
					enum_fields = enum_fields.slice(*option) unless option == true

					enum_fields.each do |field, field_schema|
						field_schema[:enum_values].each { |value| yield field, value }
					end
				end

				def all_enum_fields
					return @all_enum_fields if @enum_values_caching && defined?(@all_enum_fields)

					@all_enum_fields =
						db.schema(table_name).to_h
							.select { |_field, schema| schema.key?(:enum_values) }
				end

				def raise_field_nonexistent(field)
					raise(
						ArgumentError,
						"'#{table_name}' table does not have '#{field}' column"
					)
				end
			end
		end
	end
end
