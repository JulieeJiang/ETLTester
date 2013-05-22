module ETLTester

	module Core
		
		class Mapping
			
			attr_reader :mapping_name, :source_sql_generator, :target_sql_generator, :mapping_items
			attr_reader :source_tables, :params_file, :pks, :source_ignored_items, :target_ignored_items
			

			def initialize mapping_name, &mapping_definiton
				@mapping_name = mapping_name
				@source_tables = []
				@source_sql_generator = SqlGenerator.new
				@target_sql_generator = SqlGenerator.new
				@mapping_items = []
				@rows = RowStub.new
				@pks = []
				@source_ignored_items, @target_ignored_items = [], []
				instance_eval &mapping_definiton
				if !@params.nil?
					arr = Dir.pwd.split('/mappings')
					if arr.size == 1
						suffix_dir = arr[0]
						prefix_dir = ''	
					else
						prefix_dir = arr.last
						arr.delete_at(arr.size - 1)
						suffix_dir = arr.join('/mappings')
					end
					params_folder = suffix_dir + '/parameters' + prefix_dir
					Dir.mkdir(params_folder) if !Dir.exist?(params_folder)
					require 'yaml'
					if File.exist?(params_folder + "/#{mapping_name}.yaml")
						existed_params = File.open(params_folder + "/#{mapping_name}.yaml") {|f| YAML::load(f)}
						if existed_params.keys != @params.to_h.keys
							File.open(params_folder + "/#{mapping_name}.yaml", 'w') {|f| f.puts @params.to_h.to_yaml}	
						end
					else
						File.open(params_folder + "/#{mapping_name}.yaml", 'w') do |f|
							f.puts @params.to_h.to_yaml
						end
					end
					@params_file = params_folder + "/#{mapping_name}.yaml"
				end
			end
			
			def declare_source_table table_name, alias_name
				raise UsageError.new("\"#{alias_name}\" is used or protected by ETLTester, please use another alias name.") if respond_to? alias_name.downcase.to_sym
				if(table_name.downcase.include?("select") && table_name.downcase.include?("from"))
					table_name = "(#{table_name})"
				end
				t = Table.new(table_name, alias_name, @source_sql_generator)
				@source_tables << t
				(class << self; self; end).class_eval do
					define_method alias_name.downcase.to_sym do
						t
					end
				end
			end
			
			def declare_cte_as sql, alias_name
				raise UsageError.new("\"#{alias_name}\" is used or protected by ETLTester, please use another alias name.") if respond_to? alias_name.downcase.to_sym
				if(table_name.downcase.include?("select") && table_name.downcase.include?("from"))
					table_name = "(#{table_name})"
				end
				@source_sql_generator.add_cte sql, alias_name
				t = CteTable.new(alias_name, @source_sql_generator)
				(class << self; self; end).class_eval do
					define_method alias_name.downcase.to_sym do
						t
					end
				end
			end


			def declare_target_table table_name, alias_name
				raise UsageError.new("\"#{alias_name}\" is used or protected by ETLTester, please use another alias name.") if respond_to? alias_name.downcase.to_sym
				t = Table.new(table_name, alias_name, @target_sql_generator)
				(class << self; self; end).class_eval do
					define_method alias_name.downcase.to_sym do
						t
					end
				end
			end

			# Use Mapping#m to define each mapping
			# Usage: m <target column>, <source column> (straight move)
			# 		or m <target column>, <block of source transformation> (define the transformation in the block)
			def m *args, &blk
				if (args.size == 2 && !block_given?)|| (args.size == 1 && block_given?)
					if block_given?
						instance_eval &blk # sql generator could generate sql accordingly.
						@source_tables.each {|source_table| source_table._reverse_columns_flag} # Ensure most paths could be executed.
						# Run "declare_source_table" twice will raise a exception, rewrite "declare_source_table" to avoid this situation. 
						(class << self; self; end).class_eval do
							def declare_source_table table_name, alias_name; end
							def declare_cte_as sql, alias_name; end
						end
						instance_eval &blk
						# Recover "declare_source_table"
						(class << self; self; end).class_eval do

							def declare_source_table table_name, alias_name 
								raise UsageError.new("\"#{alias_name}\" is used or protected by ETLTester, please use another alias name.") if respond_to? alias_name.downcase.to_sym
								if(table_name.downcase.include?("select") && table_name.downcase.include?("from"))
									table_name = "(#{table_name})"
								end
								t = Table.new(table_name, alias_name, @source_sql_generator)
								@source_tables << t
								(class << self; self; end).class_eval do
									define_method alias_name.downcase.to_sym do
										t
									end
								end
							end

							def declare_cte_as sql, alias_name
								raise UsageError.new("\"#{alias_name}\" is used or protected by ETLTester, please use another alias name.") if respond_to? alias_name.downcase.to_sym
								@source_sql_generator.add_cte sql, alias_name
								t = CteTable.new(alias_name, @source_sql_generator)
								(class << self; self; end).class_eval do
									define_method alias_name.downcase.to_sym do
										t
									end
								end
							end

						end
						@mapping_items << {target: args[0], transfrom_logic: blk}
					else
						@mapping_items << {target: args[0], transfrom_logic: args[1]}
					end
					@rows.add_key(args[0].column_name.to_s.downcase.to_sym)
				else
					raise UsageError.new("Usage of m: m <target column>, <source column> or m <target column>, <block of source transformation>")
				end
			end

			
			# Set target column as primary key.
			def mp *args, &blk
				m *args, &blk
				@pks << args[0].column_name
			end

			def lookup table, join_condition
				IntermediateTable.new(@source_sql_generator).left_join table, join_condition
			end

			def link table, join_condition
				IntermediateTable.new(@source_sql_generator).inner_join table, join_condition
			end

			alias_method :left_join, :lookup
			alias_method :inner_join, :link

			alias_method :original_method_missing, :method_missing
			def method_missing method_name, *args, &blk
				if args.size == 0 && !block_given?
					raise UsageError.new("Undefined alias for \"#{method_name}\".")
				end
				original_method_missing method_name, *args, &blk
			end

			def rows
				@rows
			end

			alias_method :row, :rows

			def params
				@params ||= ParameterStub.new
			end

			alias_method :param, :params

			attr_reader :source_filter, :target_filter
			def set_source_filter &filter
				@source_filter = filter
				instance_eval &filter
			end

			def set_target_filter &filter
				@target_filter = filter
				instance_eval &filter
			end

			def define_variable variable_name, &how
				@variables ||= {}
				@fake_variables ||= FakeVariableSet.new
				@variables[variable_name] = how
				@fake_variables[variable_name] = VariableStub.new
			end

			def variables
				@fake_variables ||= FakeVariableSet.new
				@fake_variables
			end

			def get_variables
				@variables
			end

			alias_method :variable, :variables

		end

		# Used for generating parameter yaml.
		class ParameterStub

			def initialize
				@keys = []
			end

			def [] key
				@keys << key if !@keys.include? key
				VariableStub.new
			end

			def to_h
				h = {}
				@keys.each {|key| h[key] = nil}
				h
			end

		end

		class RowStub

			def initialize
				@keys = []
			end

			def add_key key
				key = key.to_s.downcase.to_sym
				@keys << key if !@keys.include? key
			end

			def [] key
				key = key.to_s.downcase.to_sym
				raise StandError.new "Undefined row[:#{key}]" if !@keys.include? key 
				VariableStub.new
			end

		end

		class FakeVariableSet
			def initialize
				@h = {}
			end

			def []= key, value
				@h[key] = value
			end

			def [] key
				raise StandError.new("Undefined varaible: #{key}") if !@h.has_key? key
				@h[key]
			end
		end


		class VariableStub
			def method_missing method_name, *args, &blk
				@flag ||= false
				@flag = !@flag
				@flag	
			end
		end

	end

end

# Alias for ETLTester::Core::Mapping#new
def mapping mapping_name, &mapping_definiton
	ETLTester::Core::Mapping.new mapping_name, &mapping_definiton
end