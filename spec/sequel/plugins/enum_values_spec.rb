# frozen_string_literal:true

describe 'Sequel::Plugins::EnumValues' do
	let(:connection) do
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

		connection
	end

	let(:item_class) do
		Class.new(Sequel::Model(connection[:items])) do
			plugin :enum_values
		end
	end

	describe 'Sequel::Model.enum_values' do
		subject { item_class.enum_values(field) }

		context 'existing :type field' do
			let(:field) { :type }

			it { is_expected.to eq %w[first second third] }
		end

		context 'existing :status field' do
			let(:field) { :status }

			it { is_expected.to eq %w[created selected canceled] }
		end

		context 'nonexistent :foo field' do
			let(:field) { :foo }

			it do
				expect { subject }.to raise_error(
					ArgumentError, "'items' table does not have 'foo' column"
				)
			end
		end

		describe '.configure' do
			describe 'caching option' do
				it 'caches by default' do
					expect(item_class.db).to receive(:schema).and_call_original.once
					5.times { item_class.enum_values(:type) }
				end

				it 'caches with true value' do
					item_class.plugin :enum_values, caching: true

					expect(item_class.db).to receive(:schema).and_call_original.once
					5.times { item_class.enum_values(:type) }
				end

				it "doesn't cache with false value" do
					item_class.plugin :enum_values, caching: false

					expect(item_class.db).to receive(:schema).and_call_original
						.exactly(5).times
					5.times { item_class.enum_values(:type) }
				end

				it 'caches fields separately' do
					expect(item_class.db).to receive(:schema).and_call_original.twice
					5.times { item_class.enum_values(:type) }
					5.times { item_class.enum_values(:status) }
				end
			end
		end
	end
end

# connection.drop_table :items
#
# connection.drop_enum :item_type
# connection.drop_enum :item_status
