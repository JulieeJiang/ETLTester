module ETLTester

	module Core
		
		# Column of table.
		class Column
			
			attr_reader :table, :column_name

			def initialize table, column_name
				@table, @column_name = table, column_name
				@flag = true # method_missing will return the value of @flag
			end
			
			# Reverse @flag to ensure all the paths could be executed.
			def _reverse_flag
				@flag = !@flag
			end


			def to_s
				"#{@table.alias_name}.#{column_name}"
			end

			def method_missing method_name, *args, &blk
				@flag
			end
		
		end

	end

end

# To avoid error during eval mapping phase.
# E.g. a = table.column; b = a + 1
class TrueClass
	def method_missing method_name, *args, &blk
		self
	end
end

class FalseClass
	def method_missing method_name, *args, &blk
		self
	end
end