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
		
			# Redifne Table's method, to avoid some problems.
			def self.define_blank_methods *method_names
				class_eval do
					method_names.each do |method_name|
						define_method method_name do |*args, &blk|
							# Do nothing
						end
					end
				end
			end

			define_blank_methods :inner_join, :left_join, :right_join


		end

		class EntireRow
			
			attr_accessor :params, :global_variables

			def initialize *sub_rows
				sub_rows.each do |sr|
					(class << self; self; end).class_eval do
						define_method sr.table.alias_name.downcase.to_sym do
							sr
						end
					end
				end
			end

			def set_raw_row_variables raw_row_variables
				@raw_row_variables = raw_row_variables
			end

			def row_variables
				@row_variables
			end

			# mapping_items: instance variable of Mapping's instance.
			def transform *mapping_items
				if !@raw_row_variables.nil?
					@row_variables = {}
					@raw_row_variables.each {|key, value| @row_variables[key] = instance_eval &value}
				end
				expected_row = {}
				mapping_items.each do |mapping_item|
					if mapping_item[:transfrom_logic].instance_of? Proc
						expected_row[mapping_item[:target].column_name.downcase] = instance_eval &mapping_item[:transfrom_logic]
					else # Straight move
						expected_row[mapping_item[:target].column_name.downcase] = instance_eval {eval mapping_item[:transfrom_logic].to_s}
					end
				end
				expected_row
			end

		end

		class DataContainer

			# mapping 		: instance of ETLTester::Core::Mapping
			# db_connection	: {type: orcale, address: xxx, user: xxx, password: xxx}
			def initialize mapping, db_connection
				
				# Get Parameters
				if !mapping.params_file.nil?
					set_params mapping.params_file
					params.each_key {|key| raise StandError.new("You must specify value for Parameter: #{key} (Mapping: #{mapping.mapping_name}).") if params[key].nil?}
				end
				
				# Get Variables
				if !mapping.global_variables.nil?
					set_global_variables mapping.get_global_variables
				end

				# Source data
				row = {}
				select_orders = []
				mapping.source_sql_generator.select.each do |column|
					row[column.table] ||= SubRow.new(column.table)
					row[column.table].add_column column.column_name
					select_orders << [column.table, column.column_name.downcase] # This order is consistebt with the select statement of sql_generator.
				end
				
				@data = []
				if mapping.source_filter.nil?
					sql_stmt = mapping.source_sql_generator.generate_sql
				else
					sql_stmt = mapping.source_sql_generator.generate_sql + " where " + (instance_eval &mapping.source_filter)
				end
				data = ETLTester::Util::DBConnection.get_data_from_db(db_connection, sql_stmt)
				# Fill data
				data.each do |record|
					new_row = {}
					row.each {|k, v| new_row[k] = v.clone}
					idx = 0					
					record.each_value do |v|
						new_row[select_orders[idx][0]].__send__("#{select_orders[idx][1]}=".to_sym, v)
						idx = idx + 1
					end					
					entire_row = EntireRow.new(*new_row.values)
					entire_row.params = @params if !@params.nil?
					entire_row.global_variables = @global_variables if !@global_variables.nil?
					entire_row.set_raw_row_variables mapping.get_row_variables if !mapping.row_variables.nil?
					@data << entire_row
				end

			end

			def transform *mapping_items
				expected_data = []
				@data.collect {|row| expected_data << row.transform(*mapping_items)}
				expected_data
			end

			private
			def set_params params_file
				require 'yaml'
				File.open(params_file) do |f|
					@params = YAML::load(f)
				end
			end

			def params
				@params
			end

			def set_global_variables global_variables
				@global_variables = {}
				global_variables.each {|key, value| @global_variables[key] = value.call}
			end

			def global_variables
				@global_variables
			end

			alias_method :global_variable, :global_variables

		end

	end

end