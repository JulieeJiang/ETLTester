module ETLTester

	module Core
		
		class Mapping
			
			attr_reader :mapping_name
					
			def initialize mapping_name, &mapping_definiton
				@mapping_name = mapping_name
				@source_sql_generator = SqlGenerator.new
				@target_sql_generator = SqlGenerator.new
				@mapping_items = []
				instance_eval &mapping_definiton
			end
			
			def declare_source_table table_name, alias_name
				if(table_name.downcase.include?("select") && table_name.downcase.include?("from"))
					table_name = "(#{table_name})"
				end
				t = Table.new(table_name, alias_name, @source_sql_generator)
				(class << self; self; end).class_eval do
					define_method alias_name.downcase.to_sym do
						t
					end
				end
			end
			
			def declare_target_table table_name, alias_name
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
						# sql generator could generate sql accordingly.
						instance_eval &blk
						#~ @mapping_items << {:target => }
					else
						
					end
				else
					raise UsageError.new("Usage of m: m <target column>, <source column> or m <target column>, <block of source transformation>")
				end
			end
		
		end
	end

end

# Alias ETLTester::Core::Mapping#new
def mapping mapping_name, &mapping_definiton
	
	new_mapping = ETLTester::Core::Mapping.new mapping_name, &mapping_definiton
	
end