module ETLTester

	module Framework
	
		# Process mapping.
		class Driver

			attr_writer :mapping, :report_folder

			def initialize
				@report_folder ||= Time.now.strftime("%Y%m%d%H%M%S")
			end

			# report_level: :all display all the result.
			#				:fail display all the failed result.
			# 				:summary only generate summary report
			# 				:smart display 200 failed result.
			def run report_level = :smart
				@report_level = report_level
				db_config = Util::Configuration::get_config :DBConnection
				max_row = Util::Configuration::get_config :MAX_ROW
				dc = Core::DataContainer.new @mapping, db_config, max_row
				result = Comparer.new(dc.expected_data, dc.actual_data, @mapping.source_ignored_items, @mapping.target_ignored_items, dc.warning_list).compare
				generate_details result
				result[0]
			end

			private
			def generate_details result
				
				if @report_level != :smmary					
					r = Util::MappingReporter.new				
					summary_header = []
					summary_content = []
					result[0].each do |key, value|
						if key != :header
							summary_header << key.to_s.split('_').map(&:capitalize).join(' ')
							summary_content << value
						end
					end

					r.addText "Detail Report: #{@mapping.mapping_name}", ''

					
					r.addHeader summary_header, :Summary
					r.addData :temp, summary_content, :Summary
					
					r.addHeader ['Result'] + result[0][:header], :Detail
					if @report_level == :all
						result[1].each_with_index do |ret, idx|
							pass_fail = ret.last ? "Pass" : "Fail"
							r.addData :"expected#{idx}", ["Expected: #{pass_fail}"] + ret[0, (ret.size - 1) / 2], :Detail
							r.addData :"actual#{idx}", ["Actual: #{pass_fail}"] + ret[(ret.size - 1) / 2, (ret.size - 1) / 2], :Detail					
						end
					end
					if @report_level == :fail
						result[1].each_with_index do |ret, idx|
							pass_fail = ret.last ? "Pass" : "Fail"
							if !ret.last
								r.addData :"expected#{idx}", ["Expected: #{pass_fail}"] + ret[0, (ret.size - 1) / 2], :Detail
								r.addData :"actual#{idx}", ["Actual: #{pass_fail}"] + ret[(ret.size - 1) / 2, (ret.size - 1) / 2], :Detail					
							end
						end
					end
					if @report_level == :smart
						failed_count = 0
						column_count = 0
						result[1].each_with_index do |ret, idx|
							pass_fail = ret.last ? "Pass" : "Fail"
							column_count = (ret.size - 1) / 2
							if !ret.last
								failed_count += 1
								r.addData :"expected#{idx}", ["Expected: #{pass_fail}"] + ret[0, (ret.size - 1) / 2], :Detail
								r.addData :"actual#{idx}", ["Actual: #{pass_fail}"] + ret[(ret.size - 1) / 2, (ret.size - 1) / 2], :Detail					
							end
							break if failed_count >= 200
						end
						if failed_count >= 200
							blank_line = ["------"]
							1.upto(column_count) {blank_line << '---'}
							r.addData :"expected201", blank_line, :Detail
							r.addData :"actual201", blank_line, :Detail
						end
					end
					report_dir = Util::Configuration::get_config(:Project_Home) + '/reports/' + @report_folder + '/details'
					Dir.mkpath(report_dir) if !Dir.exist?(report_dir)
					r.generate @mapping.mapping_name + '_' + Time.now.strftime("%H%M%S"), report_dir
				end
			end

		end

	end

end