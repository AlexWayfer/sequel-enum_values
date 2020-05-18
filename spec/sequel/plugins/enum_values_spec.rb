# frozen_string_literal:true

describe Sequel::Plugins::EnumValues do
	type_enum_values = %w[one another yet_another]
	status_enum_values = %w[created selected canceled]
	item_enum_values = type_enum_values + status_enum_values

	let(:connection) { Sequel.connect('mock://postgres') }

	let(:item_class) do
		Class.new(Sequel::Model(:items)) do
			plugin :enum_values
		end
	end

	before do
		## https://github.com/jeremyevans/sequel/blob/e61fcf297eed92342cee6c5016c90874e8da1449/spec/extensions/pg_enum_spec.rb#L9-L19

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
			let(:enum_values_options) { {} }

			before { item_class.plugin :enum_values, **enum_values_options }

			describe 'caching option' do
				shared_examples 'works correctly' do
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

					include_examples 'works correctly'
				end

				describe 'caches with true value' do
					subject do
						5.times { item_class.enum_values(:type) }
					end

					let(:enum_values_options) { { caching: true } }
					let(:all_enum_fields_received_times) { 1 }
					let(:schema_received_times) { 1 }

					include_examples 'works correctly'
				end

				describe "doesn't cache with false value" do
					subject do
						5.times { item_class.enum_values(:type) }
					end

					let(:enum_values_options) { { caching: false } }
					let(:all_enum_fields_received_times) { 5 }
					let(:schema_received_times) { 5 }

					include_examples 'works correctly'
				end

				describe 'caches fields separately' do
					subject do
						5.times { item_class.enum_values(:type) }
						5.times { item_class.enum_values(:status) }
					end

					let(:all_enum_fields_received_times) { 2 }
					let(:schema_received_times) { 1 }

					include_examples 'works correctly'
				end
			end

			describe 'predicate_methods option' do
				convert_enum_values_to_predicate_methods = lambda do |enum_values|
					enum_values.map { |enum_value| :"#{enum_value}?" }
				end

				status_enum_predicate_methods =
					convert_enum_values_to_predicate_methods.call status_enum_values
				type_enum_predicate_methods =
					convert_enum_values_to_predicate_methods.call type_enum_values
				item_enum_predicate_methods =
					convert_enum_values_to_predicate_methods.call item_enum_values

				shared_examples(
					'for all enum predicate methods'
				) do |predicate_method_names, *expectations|
					predicate_method_names.each do |predicate_method_name|
						describe predicate_method_name do
							subject { item_class.new.public_send(predicate_method_name) }

							it do
								Array(expectations).each do |expectation|
									instance_exec(&expectation)
								end
							end
						end
					end
				end

				context 'with default' do
					include_examples 'for all enum predicate methods',
						item_enum_predicate_methods,
						-> { expect { subject }.to raise_error(NoMethodError) }
				end

				context 'with true value' do
					let(:enum_values_options) { { predicate_methods: true } }

					include_examples 'for all enum predicate methods',
						item_enum_predicate_methods,
						-> { expect(subject).to be false }
				end

				context 'with false value' do
					let(:enum_values_options) { { predicate_methods: false } }

					include_examples 'for all enum predicate methods',
						item_enum_predicate_methods,
						-> { expect { subject }.to raise_error(NoMethodError) }
				end

				context 'with Array value' do
					let(:enum_values_options) { { predicate_methods: %i[status] } }

					include_examples 'for all enum predicate methods',
						status_enum_predicate_methods,
						-> { expect(subject).to be false }

					include_examples 'for all enum predicate methods',
						type_enum_predicate_methods,
						-> { expect { subject }.to raise_error(NoMethodError) }
				end

				context 'with Symbol value' do
					let(:enum_values_options) { { predicate_methods: :status } }

					include_examples 'for all enum predicate methods',
						status_enum_predicate_methods,
						-> { expect(subject).to be false }

					include_examples 'for all enum predicate methods',
						type_enum_predicate_methods,
						-> { expect { subject }.to raise_error(NoMethodError) }
				end
			end

			shared_context('with filter_methods environment') do
				subject(:enum_filter) { item_class.dataset.public_send(enum_value) }

				let(:filter_sql) do
					"SELECT * FROM \"items\" WHERE (\"#{field}\" = '#{enum_value}')"
				end
			end

			shared_examples('returns correct sql') do |field, field_value|
				subject { enum_filter.sql }

				describe field_value do
					let(:field) { field }
					let(:enum_value) { field_value }

					it { is_expected.to eq filter_sql }
				end
			end

			shared_examples('raises NoMethodError') do |field_value|
				describe field_value do
					let(:enum_value) { field_value }

					it { expect { enum_filter }.to raise_error(NoMethodError) }
				end
			end

			describe 'filter_methods default option' do
				include_context('with filter_methods environment')

				item_enum_values.each do |filter_method_name|
					include_examples('raises NoMethodError', filter_method_name)
				end
			end

			describe 'filter_methods true option' do
				let(:enum_values_options) { { filter_methods: true } }

				include_context('with filter_methods environment')

				type_enum_values.each do |filter_method_name|
					include_examples('returns correct sql', :type, filter_method_name)
				end

				status_enum_values.each do |filter_method_name|
					include_examples('returns correct sql', :status, filter_method_name)
				end
			end

			describe 'filter_methods false option' do
				let(:enum_values_options) { { filter_methods: false } }

				include_context('with filter_methods environment')

				item_enum_values.each do |filter_method_name|
					include_examples('raises NoMethodError', filter_method_name)
				end
			end

			describe 'filter_methods Array option' do
				let(:enum_values_options) { { filter_methods: %i[status] } }

				include_context('with filter_methods environment')

				status_enum_values.each do |filter_method_name|
					include_examples('returns correct sql', :status, filter_method_name)
				end

				type_enum_values.each do |filter_method_name|
					include_examples('raises NoMethodError', filter_method_name)
				end
			end

			describe 'filter_methods Symbol option' do
				let(:enum_values_options) { { filter_methods: :status } }

				include_context('with filter_methods environment')

				status_enum_values.each do |filter_method_name|
					include_examples('returns correct sql', :status, filter_method_name)
				end

				type_enum_values.each do |filter_method_name|
					include_examples('raises NoMethodError', filter_method_name)
				end
			end
		end
	end
end

# connection.drop_table :items
#
# connection.drop_enum :item_type
# connection.drop_enum :item_status
