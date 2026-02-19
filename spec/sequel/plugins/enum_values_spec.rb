# frozen_string_literal:true

describe Sequel::Plugins::EnumValues do
	let(:type_enum_values) { %w[first second third] }
	let(:status_enum_values) { %w[created selected canceled] }
	let(:item_enum_values) { type_enum_values + status_enum_values }

	let(:connection) { Sequel.connect('mock://postgres') }

	let(:item_class) do
		Class.new(Sequel::Model(:items)) do
			plugin :enum_values
		end
	end

	before do
		## https://github.com/jeremyevans/sequel/blob/e61fcf297eed92342cee6c5016c90874e8da1449/spec/extensions/pg_enum_spec.rb#L9-L19

		type_enum_values = self.type_enum_values
		status_enum_values = self.status_enum_values
		connection.define_singleton_method :schema_parse_table do |*|
			[
				[:items,  { oid: 1 }],
				[:type,   { enum_values: type_enum_values }],
				[:status, { enum_values: status_enum_values }]
			]
		end

		# connection.define_singleton_method :_metadata_dataset do |*args|
		# 	super.with_fetch(
		# 		[
		# 			%w[first second third].map { |value| { v: 1, enumlabel: value } },
		# 			[{ typname: 'item_type', v: 212_389 }]
		# 		]
		# 	)
		# end

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
	end

	describe 'Sequel::Model.enum_values' do
		subject(:enum_values) { item_class.enum_values(field) }

		context 'with existing :type field' do
			let(:field) { :type }

			it { is_expected.to eq type_enum_values }
		end

		context 'with existing :status field' do
			let(:field) { :status }

			it { is_expected.to eq status_enum_values }
		end

		context 'with nonexistent :foo field' do
			let(:field) { :foo }

			it do
				expect { enum_values }.to raise_error(
					ArgumentError, "'items' table does not have 'foo' column"
				)
			end
		end

		describe '.configure' do
			describe 'caching option' do
				shared_examples 'cached correctly' do
					before do
						allow(item_class).to receive(:all_enum_fields).and_call_original
						allow(item_class.db).to receive(:schema).and_call_original

						subject
					end

					it do
						expect(item_class).to have_received(:all_enum_fields)
							.exactly(all_enum_fields_received_times).times
					end

					it do
						expect(item_class.db).to have_received(:schema)
							.exactly(schema_received_times).times
					end
				end

				describe 'caches by default' do
					subject do
						5.times { item_class.enum_values(:type) }
					end

					let(:all_enum_fields_received_times) { 1 }
					let(:schema_received_times) { 1 }

					it_behaves_like 'cached correctly'
				end

				describe 'caches with true value' do
					subject do
						5.times { item_class.enum_values(:type) }
					end

					before do
						item_class.plugin :enum_values, caching: true
					end

					let(:all_enum_fields_received_times) { 1 }
					let(:schema_received_times) { 1 }

					it_behaves_like 'cached correctly'
				end

				describe "doesn't cache with false value" do
					subject do
						5.times { item_class.enum_values(:type) }
					end

					before do
						item_class.plugin :enum_values, caching: false
					end

					let(:all_enum_fields_received_times) { 5 }
					let(:schema_received_times) { 5 }

					it_behaves_like 'cached correctly'
				end

				describe 'caches fields separately' do
					subject do
						5.times { item_class.enum_values(:type) }
						5.times { item_class.enum_values(:status) }
					end

					let(:all_enum_fields_received_times) { 2 }
					let(:schema_received_times) { 1 }

					it_behaves_like 'cached correctly'
				end
			end

			describe 'predicate_methods option' do
				def convert_enum_values_to_predicate_methods(enum_values)
					enum_values.map { |enum_value| :"#{enum_value}?" }
				end

				let(:status_enum_predicate_methods) do
					convert_enum_values_to_predicate_methods status_enum_values
				end

				let(:type_enum_predicate_methods) do
					convert_enum_values_to_predicate_methods type_enum_values
				end

				let(:item_enum_predicate_methods) do
					convert_enum_values_to_predicate_methods item_enum_values
				end

				shared_examples 'defining predicate methods' do
					let(:item) { item_class.new }

					specify do
						predicate_method_names.each do |predicate_method_name|
							expect(item.public_send(predicate_method_name)).to be false
						end
					end
				end

				shared_examples 'not defining predicate methods' do
					let(:item) { item_class.new }

					specify do
						predicate_method_names.each do |predicate_method_name|
							expect { item.public_send(predicate_method_name) }.to raise_error(NoMethodError)
						end
					end
				end

				context 'with default' do
					it_behaves_like 'not defining predicate methods' do
						let(:predicate_method_names) { item_enum_predicate_methods }
					end
				end

				context 'with true value' do
					before do
						item_class.plugin :enum_values, predicate_methods: true
					end

					it_behaves_like 'defining predicate methods' do
						let(:predicate_method_names) { item_enum_predicate_methods }
					end
				end

				context 'with false value' do
					before do
						item_class.plugin :enum_values, predicate_methods: false
					end

					it_behaves_like 'not defining predicate methods' do
						let(:predicate_method_names) { item_enum_predicate_methods }
					end
				end

				context 'with Array value' do
					before do
						item_class.plugin :enum_values, predicate_methods: %i[status]
					end

					it_behaves_like 'defining predicate methods' do
						let(:predicate_method_names) { status_enum_predicate_methods }
					end

					it_behaves_like 'not defining predicate methods' do
						let(:predicate_method_names) { type_enum_predicate_methods }
					end
				end

				context 'with Symbol value' do
					before do
						item_class.plugin :enum_values, predicate_methods: :status
					end

					it_behaves_like 'defining predicate methods' do
						let(:predicate_method_names) { status_enum_predicate_methods }
					end

					it_behaves_like 'not defining predicate methods' do
						let(:predicate_method_names) { type_enum_predicate_methods }
					end
				end
			end
		end
	end
end

# connection.drop_table :items
#
# connection.drop_enum :item_type
# connection.drop_enum :item_status
