module ETLTester

	module Core
		
		class Column
			
			attr_reader :table, :column_name

			def initialize table, column_name
				@table, @column_name = table, column_name
				@flag = true # method_missing will return the value of @flag
			end
			
			def _reverse_flag
				@flag = !@flag
			end


			def to_s
				"#{@table.alias_name}.#{column_name}"
			end

			def method_missing method_missing, *args, &blk
				@flag
			end
		
		end

	end

end