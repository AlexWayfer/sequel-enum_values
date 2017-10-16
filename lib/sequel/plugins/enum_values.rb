# frozen_string_literal: true

module Sequel
	module Plugins
		module EnumValues
			VERSION = '1.0.0'

			## Module for class methods
			module ClassMethods
				def enum_values(field)
					field_schema = db.schema(table_name).to_h[field]
					unless field_schema
						raise(
							ArgumentError,
							"'#{table_name}' table does not have '#{field}' column"
						)
					end
					field_schema[:enum_values]
				end
			end
		end
	end
end
