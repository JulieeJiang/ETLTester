module ETLTester

	module Core
	
		class SqlGenerator
		
			attr_reader :select

			def initialize
				@select = []
				@from = {}
				@cte = {} # commen table expression.
			end
			
			def add_select column
				@select << column if !@select.include? column
			end
			
			def add_cte sql_txt, alias_name
				raise SqlGeneratorError.new("'#{alias_name}' is already used.") if(@cte.has_key?(alias_name) || @from.has_key?(alias_name))
				@cte[alias_name] = sql_txt
			end

			def add_table table_name, alias_name, join_details = nil
				if @from[alias_name].nil?
					@from[alias_name] = [table_name, join_details]
				else
					# @from[alias_name][1]: join_details 
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
			
			def add_where where_stmt
				@where = where_stmt
			end

			def generate_sql
				sql_txt = ""
				if !@cte.empty?
					@cte.each do |alias_name, sql|
						sql_txt = %Q{#{sql_txt}with #{alias_name} as (#{sql})\n}
					end	
				end
				sql_txt = "#{sql_txt}Select\n\t"
				if @select.empty?
					sql_txt = "#{sql_txt}*\nFrom\n\t"
				else	
					sql_txt = "#{sql_txt}#{@select.collect {|col| "#{col.table.alias_name}.#{col.column_name}"}.join("\n\t, ")}\nFrom\n\t"
				end
				first_line = ''
				lines = []
				@from.each do |k, v|
					if v[1].nil?	# v[0] is table name, v[1] is join_details.
						if first_line == ''
							first_line = "#{v[0]} #{k}\n"
						else
							raise SqlGeneratorError.new("Invalid SqlGenerator: Maybe something wrong with \"#{first_line}\" or \"#{v[0]} #{k}\"")
						end
					else
						lines << "#{v[1][:join_type]}\n\t#{v[0]} #{k} on #{v[1][:condition]}"
					end
				end
				sql_txt = sql_txt + first_line + lines.join("\n")
				if @where.nil?
					sql_txt
				else
					sql_txt + "\nwhere\n\t" + @where
				end			
			end

			def sql_for_count
				sql_txt = ""
				if !@cte.empty?
					@cte.each do |alias_name, sql|
						sql_txt = %Q{#{sql_txt}with #{alias_name} as (#{sql})\n}
					end	
				end
				sql_txt = "#{sql_txt}Select\n\tcount(1)\nFrom\n\t"
				first_line = ''
				lines = []
				@from.each do |k, v|
					if v[1].nil?	# v[0] is table name, v[1] is join_details.
						if first_line == ''
							first_line = "#{v[0]} #{k}\n"
						else
							raise SqlGeneratorError.new("Invalid SqlGenerator: Maybe something wrong with \"#{first_line}\" or \"#{v[0]} #{k}\"")
						end
					else
						lines << "#{v[1][:join_type]}\n\t#{v[0]} #{k} on #{v[1][:condition]}"
					end
				end
				sql_txt = sql_txt + first_line + lines.join("\n")
				if @where.nil?
					sql_txt
				else
					sql_txt + "\nwhere\n\t" + @where
				end
			end
		
		end
	
	end

end