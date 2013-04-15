module ETLTester

	module Core
	
		class Table	
			
			attr_reader :table_name, :alias_name
			
			def initialize table_name, alias_name, sql_generator
				@table_name = table_name
				@alias_name = alias_name
				@sql_generator = sql_generator
				@columns = []
			end
			
			def inner_join table, join_condition
				@sql_generator.add_table @table_name, @alias_name
				@sql_generator.add_table table.table_name, table.alias_name, condition: join_condition, join_type: "inner join"
			end
			
			def left_join table, join_condition
				@sql_generator.add_table @table_name, @alias_name
				@sql_generator.add_table table.table_name, table.alias_name, condition: join_condition, join_type: "left join"
			end

			def right_join table, join_condition
				@sql_generator.add_table @table_name, @alias_name
				@sql_generator.add_table table.table_name, table.alias_name, condition: join_condition, join_type: "right join"
			end
			
			alias_method :original_method_missing, :method_missing
			
			def method_missing method_name, *args, &blk			
				if args.size == 0 && !block_given?
					new_column = Column.new(self, method_name.to_s)
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
			
		end
	
	end

end