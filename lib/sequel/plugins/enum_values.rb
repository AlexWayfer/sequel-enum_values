# frozen_string_literal: true

module Sequel
	module Plugins
		## Plugin for getting enum values from PostgreSQL by field name
		module EnumValues
			VERSION = '1.0.0'

			def self.apply(model, _options = {})
				model.instance_exec do
					@cache = {}
					@caching = true
				end
			end

			def self.configure(model, options = {})
				model.instance_exec do
					@caching = options.fetch(:caching, @caching)

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
				def enum_values(field)
					if @caching && (cached_values = @cache[field])
						return cached_values
					end

					field_schema = all_enum_fields[field]
					raise_field_nonexistent(field) if field_schema.nil?

					enum_values = field_schema[:enum_values]
					@cache[field] = enum_values if @caching
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
					return @all_enum_fields if @caching && defined? @all_enum_fields
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
