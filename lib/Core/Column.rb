module ETLTester

	module Core
		
		class Column
			
			attr_reader :table, :column_name

			def initialize table, column_name
				@table, @column_name = table, column_name
			end
			
			def method_missing method_missing, *args, &blk
				#{Do nothing} 
			end
		
		end

	end

end