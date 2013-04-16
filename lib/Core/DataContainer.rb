module ETLTester

	module Core
	
		class SubRow
			
			attr_reader :table

			def initialize table
				@table = table
				@columns = []
			end

			def add_column column_name
				if !@columns.include? column_name
					(class << self; self; end).class_eval {attr_accessor column_name.to_s.downcase.to_sym}
					@columns << column_name
				end
			end
		end

		class EntireRow
			def initialize *sub_rows
				sub_rows.each do |sr|
					(class << self; self; end).class_eval do
						define_method sr.table.alias_name.downcase.to_sym do
							sr
						end
					end
				end
			end

		end

		class DataContainer
		
			# data 			: return of ETLTester::Util::DBConnection::get_data_from_db
			# sql_generator	: instance of SqlGnerator
			def initialize data, sql_generator
				row = {}
				select_orders = []
				sql_generator.select.each do |column|
					row[column.table] ||= SubRow.new(column.table)
					row[column.table].add_column column.column_name
					select_orders << [column.table, column.column_name.downcase] # This order is consistebt with the select statement of sql_generator.
				end
				
				@data = []

				# Fill data
				data.each do |record|
					new_row = {}
					row.each {|k, v| new_row[k] = v.clone}
					idx = 0					
					record.each_value do |v|
						new_row[select_orders[idx][0]].__send__("#{select_orders[idx][1]}=".to_sym, v)
						idx = idx + 1
					end					
					@data << EntireRow.new(*new_row.values)
				end

			end

			def transform &blk
				@data.collect {|d| d.instance_eval &blk}
			end

		end

	end

end