module ETLTester

	module Core
	
		class SqlGenerator
		
			attr_reader :select

			def initialize
				@select = []
				@from = {}
			end
			
			def add_select column
				@select << column
			end
			
			def add_table table_name, alias_name, join_details = nil
				if @from[alias_name].nil?
					@from[alias_name] = [table_name, join_details]
				else
					if @from[alias_name][1].nil? && !join_details.nil?
						@from[alias_name] = [@from[alias_name][0], join_details]
					else
						if !@from[alias_name][1].nil? && !join_details.nil?
							if join_details == @from[alias_name][1]
								# Do Nothing.
							else
								raise SqlGeneratorError.new("Invalid Join: #{table_name} #{alias_name}")
							end
						end
					end
				end
			end
			
			def generate_sql
				sql_txt = "Select\n\t"
				sql_txt = "#{sql_txt}#{@select.collect {|col| "#{col.table.alias_name}.#{col.column_name}"}.join("\n\t, ")}\nFrom\n\t"
				first_line = ''
				lines = []
				@from.each do |k, v|
					if v[1].nil?	# v[0] is table name, v[1] is join_details.
						if first_line == ''
							first_line = "#{v[0]} #{k}\n"
						else
							raise SqlGeneratorError.new('Invalid SqlGenerator')
						end
					else
						lines << "#{v[1][:join_type]}\n\t#{v[0]} #{k} on #{v[1][:condition]}"
					end
				end
				sql_txt = sql_txt + first_line + lines.join("\n")			
			end
		
		end
	
	end

end