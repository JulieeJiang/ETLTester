module ETLTester

	module Core
	
		# Table...
		class Table	
			
			attr_reader :table_name, :alias_name
			
			def initialize table_name, alias_name, sql_generator
				@table_name = table_name
				@alias_name = alias_name
				@sql_generator = sql_generator
				@columns = []
			end

			def join table, join_type, join_condition
				@sql_generator.add_table @table_name, @alias_name
				@sql_generator.add_table table.table_name, table.alias_name, condition: join_condition, join_type: join_type
				IntermediateTable.new @sql_generator
			end

			def inner_join table, join_condition
				join table, "inner join", join_condition
			end
			
			def left_join table, join_condition
				join table, "left join", join_condition
			end

			def right_join table, join_condition
				join table, "right join", join_condition
			end
			
			def _reverse_columns_flag
				@columns.each {|column| column._reverse_flag}
			end


			alias_method :original_method_missing, :method_missing
			
			def method_missing method_name, *args, &blk			
				return __send__(method_name, *args, &blk) if respond_to? method_name.to_s.downcase
				method_name = method_name.to_s.downcase.to_sym
				if args.size == 0 && !block_given?
					new_column = Column.new(self, method_name.to_s)
					
					# Notify sql_generator: Here is a new column being added.
					@sql_generator.add_select new_column
					@sql_generator.add_table @table_name, @alias_name
					(class << self; self; end).class_eval do
						define_method method_name do
							new_column
						end
					end
					@columns << new_column
					return(__send__(method_name))			
				end
				original_method_missing method_name, *args, &blk
			end
			
		end # class Table
		
		# Common Table Expression.
		class CteTable < Table
		
			def initialize alias_name, sql_generator
				super(alias_name, alias_name, sql_generator)
			end

		end

		# Intermediate table. Used for join chain: e.g. s1.inner_join(s2, "condition1").left_join(s3, "condition2")
		class IntermediateTable < Table
			
			attr_reader :sql_generator

			def initialize sql_generator
				@sql_generator = sql_generator
			end

			def join table, join_type, join_condition
				@sql_generator.add_table table.table_name, table.alias_name, condition: join_condition, join_type: join_type
				IntermediateTable.new @sql_generator
			end

		end
	
	end

end