module ETLTester

	module Core

		#                               Main Dataset
		# ----------------------------------------------------------------------
		# | a.col1 a.col2 a.col3 | b.col1 b.col2 b.col3 | c.col1 c.col2 c.col3 |
		# |	 a		  b     c    |	  d	     e       f  |    g      h       i  |
		# |  g        k     l    |    m      n       o  |    p      q       r  |
		# |  s        t     u    |    v      w       x  |    y      z       0  |
		# ----------------------------------------------------------------------
		# |-----SubDataSet1------|-----SubDataSet2------|-----SubDataSet3------|

		class SubDataSet
			def initialize
				@columns = []
			end

			def _add_column column_name
				if !@columns.include? column_name
					(class << self; self; end).class_eval {attr_accosser column_name.to_s.downcase.to_sym}
					@columns << column_name
				end
			end
		end


		# Generate object to given mapping_runner
		# mapping_runner	: instance of MappingRunner
		# dataset_name		: a meanful name for dataset
		# data 				: return of ETLTester::Util::DBConnection::get_data_from_db
		# sql_generate		: instance of SqlGnerate
		def self.data_to_object mapping_runner, dataset_name, data ,sql_generate

			mapping_runner.instance_eval do

				# Generate sub dataset.
				tables = {}
				select_orders = []
				sql_generate.select.each do |column|
					tables[column.table] ||= SubDataSet.new
					tables[column.table]._add_column column.column_name
					select_orders << [column.table.alias_name.downcase.to_sym, column_name.downcase.to_sym]
				end

				# Add sub dataset to mapping runner.
				(class << self; self; end).class_eval do
					
					tables.each do |table, sub_dataset|
						
						define_method table.alias_name.downcase.to_sym do
							sub_dataset
						end

					end

					# Fill data to data_of_runner.
					data_of_runner = []
					
					data.each do |record|

					end

					class_variable_set("@@#{dataset_name.to_s}".to_sym, data_of_runner)

				end

			end

		end # def self.data_to_object

	end

end