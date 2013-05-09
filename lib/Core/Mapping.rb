module ETLTester

	module Core
		
		class Mapping
			
			attr_reader :mapping_name, :source_sql_generator, :target_sql_generator, :mapping_items
					
			def initialize mapping_name, &mapping_definiton
				@mapping_name = mapping_name
				@source_tables = []
				@source_sql_generator = SqlGenerator.new
				@target_sql_generator = SqlGenerator.new
				@mapping_items = []
				@pks = []
				instance_eval &mapping_definiton
				if !@params.nil?
					arr = Dir.pwd.split('/mappings')
					params_folder = arr[0] + '/parameters' + (arr[1].nil? ? "" : arr[1])
					Dir.mkdir(params_folder) if !Dir.exist?(params_folder)
					if File.exist?(params_folder + "/#{mapping_name}.yaml")
						# Verify
					else
						File.open(params_folder + "/#{mapping_name}.yaml", 'w') do |f|
							require 'yaml'
							f.puts @params.to_h.to_yaml
						end
					end 
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
				else
					raise UsageError.new("Usage of m: m <target column>, <source column> or m <target column>, <block of source transformation>")
				end
			end

			
			def mp *args, &blk
				m *args, &blk
				@pks << args[0]
			end


			alias_method :original_method_missing, :method_missing
			def method_missing method_name, *args, &blk
				if args.size == 0 && !block_given?
					raise UsageError.new("Undefined alias for \"#{method_name}\".")
				end
				original_method_missing method_name, *args, &blk
			end


			def params
				@params ||= ParameterStub.new
			end


			def source_filter &filter
				@source_filter_definition = filter
			end

			def target_filter &filter
				@target_filter_definition = filter
			end

		end

		# Used for generating parameter yaml.
		class ParameterStub

			def initialize
				@keys = []
			end

			def [] key
				@keys << key if !@keys.include? key
			end

			def to_h
				h = {}
				@keys.each {|key| h[key] = nil}
				h
			end

		end
	end

end

# Alias for ETLTester::Core::Mapping#new
def mapping mapping_name, &mapping_definiton
	ETLTester::Core::Mapping.new mapping_name, &mapping_definiton
end