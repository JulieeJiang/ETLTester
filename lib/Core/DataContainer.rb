module ETLTester

	module Core
	
		class SubRow
			
			attr_reader :table

			def initialize table
				@table = table
				@columns = []
			end

			def _add_column column_name
				if !@columns.include? column_name
					(class << self; self; end).class_eval {attr_accessor column_name.to_s.downcase.to_sym}
					@columns << column_name
				end
			end
			
			# Redifne Table's method, to avoid some problems.
			def self.define_blank_methods *method_names
				class_eval do
					method_names.each do |method_name|
						define_method method_name do |*args, &blk|
							self # Do nothing
						end
					end
				end
			end

			# Used for debug.
			def inspect
				@columns.collect {|column| column + ": " + __send__(column.to_sym).to_s}.join(', ')
			end

			alias_method :original_method_missing, :method_missing
			
			def method_missing method_name, *args, &blk			
				if respond_to? method_name.to_s.downcase.to_sym 
					return __send__(method_name.to_s.downcase.to_sym, *args, &blk) 
				else
					original_method_missing method_name, *args, &blk
				end
			end

			define_blank_methods :inner_join, :left_join, :right_join, :lookup, :link


		end

		class EntireRow
			
			attr_accessor :params, :variables
			attr_reader :rows

			def initialize *sub_rows
				sub_rows.each do |sr|
					(class << self; self; end).class_eval do
						define_method sr.table.alias_name.downcase.to_sym do
							sr
						end
					end
				end
				@sub_rows = sub_rows
				@rows = SymbolHash.new
			end

			# Used for debug.
			def inspect
				@sub_rows.map(&:inspect).join("\n")
			end

			alias_method :variable, :variables
			alias_method :param, :params
			alias_method :row, :rows

			# mapping_items: instance variable of Mapping's instance.
			def transform *mapping_items
				expected_row = {}
				mapping_items.each do |mapping_item|
					if mapping_item[:transfrom_logic].instance_of? Proc
						expected_row[mapping_item[:target].column_name.downcase.to_sym] = instance_eval &mapping_item[:transfrom_logic]
					else # Straight move
						expected_row[mapping_item[:target].column_name.downcase.to_sym] = instance_eval {eval mapping_item[:transfrom_logic].to_s}
					end
					@rows[mapping_item[:target].column_name.downcase.to_sym] = expected_row[mapping_item[:target].column_name.downcase.to_sym]
				end
				expected_row
			end

			# Redifne Table's method, to avoid some problems.
			def self.define_blank_methods *method_names
				class_eval do
					method_names.each do |method_name|
						define_method method_name do |*args, &blk|
							self # Do nothing
						end
					end
				end
			end

			define_blank_methods :inner_join, :left_join, :right_join, :lookup, :link, :declare_source_table

		end

		class DataContainer

			attr_reader :expected_data, :actual_data, :warning_list

			# mapping 		: instance of ETLTester::Core::Mapping
			# db_connection	: {type: orcale, address: xxx, user: xxx, password: xxx}
			# max_row		: Configuration[:MAX_ROW]
			def initialize mapping, source_db_connection, target_db_connection, max_row
				$timer ||= ETLTester::Util::Timer.new
				
				@warning_list = []

				$timer.record "Run mapping #{mapping.mapping_name}."

				# Get Parameters
				if !mapping.params_file.nil?
					set_params mapping.params_file
					params.each_key {|key| raise StandError.new("You must specify value for Parameter: #{key} (Mapping: #{mapping.mapping_name}).") if params[key].nil?}
					$timer.record "Get parameter." 
				end
				
				# Get Variables
				if !mapping.get_variables.nil?
					set_variables mapping.get_variables
					$timer.record "Get variables." 
				end
				@mapping, @max_row = mapping, max_row
				@source_db_connection, @target_db_connection = source_db_connection, target_db_connection
				# Get @actual_data
				raise StandError.new "You should specify pks(Usage: mp target.column, source.column) within mapping #{@mapping.mapping_name}" if @mapping.pks.empty?
				total_row = set_actual_data
				$timer.record "Extract actual data from database. #{total_row} records." 

				total_row = set_expected_data
				$timer.record "Extract expected data from database. #{total_row} records." 

			end

			private

			def set_actual_data
				if @mapping.target_filter.nil?
					sql_stmt = @mapping.target_sql_generator.generate_sql
					count_sql = @mapping.target_sql_generator.generate_count_sql
				else
					sql_stmt = @mapping.target_sql_generator.generate_sql + " where " + (instance_eval &@mapping.target_filter)
					count_sql = @mapping.target_sql_generator.generate_count_sql + " where " + (instance_eval &@mapping.target_filter)
				end
				total_row = Util::DBConnection.get_data_from_db(@target_db_connection, count_sql)[0][0]
				raise StandError.new("Total row number(#{total_row}) is bigger the max row number(#{@max_row}). Try to limit your returns or change MAX_ROW in configuration.yaml") if @max_row < total_row
				
				@actual_data = {}
				Util::DBConnection.get_transformed_data(@target_db_connection, sql_stmt) do |record|
					k = {}
					actual_record = {}
					record.each_with_index do |value, idx| 
						if @mapping.pks.include? @mapping.target_sql_generator.select[idx].column_name
							k[@mapping.target_sql_generator.select[idx].column_name.to_sym] = value
						end
						actual_record[@mapping.target_sql_generator.select[idx].column_name.to_sym] = value
					end
					if !@actual_data[k].nil?
						@warning_list << "Mapping #{@mapping.mapping_name}: Duplicate records use same PK: #{k}"
						warn "Mapping #{@mapping.mapping_name}: Duplicate records use same PK: #{k}"
					end
					@actual_data[k] = actual_record
				end
				total_row
			end

			def set_expected_data
				row = {}
				select_orders = []
				@mapping.source_sql_generator.select.each do |column|
					row[column.table] ||= SubRow.new(column.table)
					row[column.table]._add_column column.column_name
					select_orders << [column.table, column.column_name.downcase] # This order is consistebt with the select statement of sql_generator.
				end

				@mapping.source_tables.each {|table| row[table] ||= SubRow.new(table)} # Some tables are only used for join.

				if @mapping.source_filter.nil?
					sql_stmt = @mapping.source_sql_generator.generate_sql
					count_sql = @mapping.source_sql_generator.generate_count_sql
				else
					sql_stmt = @mapping.source_sql_generator.generate_sql + " where " + (instance_eval &@mapping.source_filter)
					count_sql = @mapping.source_sql_generator.generate_count_sql + " where " + (instance_eval &@mapping.source_filter)
				end
				total_row = Util::DBConnection.get_data_from_db(@source_db_connection, count_sql)[0][0]
				raise StandError.new("Total row number(#{total_row}) is bigger the max row number(#{@max_row}). Try to limit your returns or change MAX_ROW in configuration.yaml") if @max_row < total_row
				@expected_data = {}
				Util::DBConnection.get_transformed_data(@source_db_connection, sql_stmt) do |record|					
					new_row = {}
					row.each {|k, v| new_row[k] = v.clone}
					record.each_with_index {|v, idx| new_row[select_orders[idx][0]].__send__(:"#{select_orders[idx][1]}=", v)}
					entire_row = EntireRow.new(*new_row.values)
					#puts entire_row.inspect
					entire_row.params = @params if !@params.nil?
					entire_row.variables = @variables if !@variables.nil?
					expected_record = entire_row.transform(*@mapping.mapping_items)
					k = {}
					@mapping.pks.each {|pk| k[pk.to_sym] = expected_record[pk.to_sym]}
					if !@expected_data[k].nil?
						@warning_list << "Mapping #{@mapping.mapping_name}: Duplicate records use same PK: #{k}"
						warn "Mapping #{@mapping.mapping_name}: Duplicate records use same PK: #{k}"
					end
					@expected_data[k] = expected_record 
				end
				total_row
			end

			def set_params params_file
				require 'yaml'
				File.open(params_file) do |f|
					@params = YAML::load(f)
				end
			end

			def params
				@params
			end

			def set_variables variables
				@variables = {}
				# variables.each {|key, value| @variables[key] = value.call}
				variables.each {|key, value| @variables[key] = instance_eval &value}
			end

			def variables
				@variables
			end

			alias_method :variable, :variables
			alias_method :param, :params

		end

		class SymbolHash < Hash
			def [] key
				super key.to_s.downcase.to_sym
			end
			
			def []= key, value
				super key.to_s.downcase.to_sym, value
			end
		end

	end

end