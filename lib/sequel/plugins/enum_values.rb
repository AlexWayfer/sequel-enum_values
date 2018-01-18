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
				end
			end

			## Module for class methods
			module ClassMethods
				def enum_values(field)
					if @caching && (cached_values = @cache[field])
						return cached_values
					end

					field_schema = db.schema(table_name).to_h[field]
					raise_field_nonexistent(field) if field_schema.nil?

					enum_values = field_schema[:enum_values]
					@cache[field] = enum_values if @caching
					enum_values
				end

				private

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
