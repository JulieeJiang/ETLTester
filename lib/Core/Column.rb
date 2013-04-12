module ETLTester

	module Core
		
		class Column
			
			def initialize table, column_name
				@table, @column_name = table, column_name
			end
			
			def method_missing method_missing, *args, &blk
				#{Do nothing} 
			end
		
		end

	end

end