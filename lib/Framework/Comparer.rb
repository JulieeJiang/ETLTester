module ETLTester

	module Framework

		class Comparer
			
			def initialize(expected_data, actual_data, source_ignored_items, target_ignored_items, warning_list)
				$timer ||= ETLTester::Util::Timer.new 
				$timer.record "Comparing..." 
				@expected_data = expected_data
				@actual_data = actual_data
				@source_ignored_items = source_ignored_items
				@target_ignored_items = target_ignored_items
				@warning_list = warning_list
			end
		
			# Return [summary, detial, warning_list]
			def compare
				summary = {}
				detial = []
				used_pks = []
				summary[:Result] = 'Pass'
				summary[:expected_data_size] = @expected_data.size
				summary[:actual_data_size] = @actual_data.size


				@expected_data.each do |pk, record|
					summary[:header] ||= record.keys
					skip_flag = false
					@source_ignored_items.each do |item| 
						skip_flag = true
						item.each do |k, v|
							if record[k] != v
								skip_flag = false
								break
							end
						end
						break if skip_flag
					end
					# Ignored items
					if skip_flag
						ret = record.values
						1.upto(record.size) {ret << "Ignored"}
						ret << true
						detial << ret
						next
					end
					# Not found in actual
					if @actual_data[pk].nil?
						ret = record.values
						1.upto(record.size) {ret << "NOT FOUND"}
						ret << false
						summary[:Result] = 'Fail'
						detial << ret
						next
					else
						ret = (record.values + @actual_data[pk].values) << (record == @actual_data[pk])
						# if !ret.last
						# 	puts "Result:"
						# 	record.each do |k, v|
						# 		puts "Expected #{k}: #{v}, #{v.class}"
						# 		puts "Actual #{k}: #{@actual_data[pk][k]}, #{@actual_data[pk][k].class}"
						# 	end
						# end
						summary[:Result] = 'Fail' if !ret.last
						detial << ret
						used_pks << pk
						next
					end

				end
				(@actual_data.keys - used_pks).each do |pk|
					skip_flag = false
					@target_ignored_items.each do |item|
						skip_flag = true
						item.each do |k, v|
							if record[k] != v
								skip_flag = false
								break
							end
						end
						break if skip_flag
					end
					# Ignored items
					if skip_flag
						ret = []
						1.upto(@actual_data[pk].size) {ret << "Ignored"}
						ret = ret + @actual_data[pk].values
						ret << true
						detial << ret
						next
					else
						ret = []
						1.upto(@actual_data[pk].size) {ret << "NOT FOUND"}
						ret = ret + @actual_data[pk].values
						ret << false
						summary[:Result] = 'Fail'
						detial << ret
						next
					end
				end

				summary[:warning] = @warning_list.empty? ? 'No warning' : "Warnings: #{@warning_list.size}, refer to log."
				$timer.record "Comparison done..." 
				return summary, detial
			end

		end
	
	end

end