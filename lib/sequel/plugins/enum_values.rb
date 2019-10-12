# frozen_string_literal: true

module Sequel
	module Plugins
		## Plugin for getting enum values from PostgreSQL by field name
		module EnumValues
			VERSION = '1.2.1'

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
			## @example Disable caching
			##   Item.plugin :enum_values, caching: false
			## @example Define predicate methods for all enum fields
			##   Item.plugin :enum_values, predicate_methods: true
			## @example Define predicate methods for specific enum fields
			##   Item.plugin :enum_values, predicate_methods: %[status type]
			## @example Define predicate methods for specific enum field
			##   Item.plugin :enum_values, predicate_methods: :status
			def self.configure(model, options = {})
				model.instance_exec do
					@enum_values_caching = options.fetch(:caching, @enum_values_caching)

					predicate_methods = options.fetch(:predicate_methods, false)

					transform_predicate_methods_to_enum_fields(predicate_methods)
						.each do |field|
							all_enum_fields[field][:enum_values].each do |enum_value|
								define_predicate_method field, enum_value
							end
						end
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

				def transform_predicate_methods_to_enum_fields(predicate_methods)
					case predicate_methods
					when TrueClass
						all_enum_fields.keys
					when FalseClass
						[]
					else
						Array(predicate_methods)
					end
				end

				def define_predicate_method(field, enum_value)
					define_method "#{enum_value}?" do
						public_send(field) == enum_value
					end
				end

				def all_enum_fields
					if @enum_values_caching && defined?(@all_enum_fields)
						return @all_enum_fields
					end

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
