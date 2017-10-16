# frozen_string_literal:true

connection = Sequel.connect('mock://postgres')

## https://github.com/jeremyevans/sequel/blob/e61fcf297eed92342cee6c5016c90874e8da1449/spec/extensions/pg_enum_spec.rb#L9-L19
connection.extend(
	Module.new do
		def schema_parse_table(*)
			[
				[:items,  { oid: 1 }],
				[:type,   { enum_values: %w[first second third] }],
				[:status, { enum_values: %w[created selected canceled] }]
			]
		end

		# def _metadata_dataset
		# 	super.with_fetch(
		# 		[
		# 			%w[first second third].map { |value| { v: 1, enumlabel: value } },
		# 			[{ typname: 'item_type', v: 212_389 }]
		# 		]
		# 	)
		# end
	end
)

# connection.extension :pg_enum
#
# connection.create_enum :item_type, %w[first second third]
# connection.create_enum :item_status, %w[created selected canceled]
#
# connection.create_table :items do
# 	primary_key :id
# 	column :type, :item_type
# 	column :status, :item_status
# end

class Item < Sequel::Model
	plugin :enum_values
end

describe 'Sequel::Plugins::EnumValues' do
	describe 'Sequel::Model.enum_values' do
		it 'should return array of pg_enum values by field name' do
			Item.enum_values(:type).should.equal %w[first second third]
		end

		it 'should return array of pg_enum values by another field name' do
			Item.enum_values(:status).should.equal %w[created selected canceled]
		end

		it 'should raise ArgumentError if there is no such column' do
			-> { Item.enum_values(:foo) }
				.should.raise(ArgumentError)
				.message.should.equal "'items' table does not have 'foo' column"
		end
	end
end

# connection.drop_table :items
#
# connection.drop_enum :item_type
# connection.drop_enum :item_status
