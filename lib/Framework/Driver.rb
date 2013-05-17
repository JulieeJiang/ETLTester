module ETLTester

	module Framework
	
		# Process mapping.
		class Driver

			attr_writer :mapping

			# report_level: :all display all the result.
			#				:fail display all the failed result.
			# 				:summary only generate summary report
			# 				:smart display 100 failed result.
			def run report_level = :smart
				@report_level = report_level
				db_config = Util::Configuration::get_config :DBConnection
				max_row = Util::Configuration::get_config :MAX_ROW
				dc = Core::DataContainer.new @mapping, db_config, max_row
				result = Comparer.new(dc.expected_data, dc.actual_data, @mapping.source_ignored_items, @mapping.target_ignored_items, dc.warning_list).compare
				generate_report result
			end

			private
			def generate_report result
				r = Util::MappingReporter.new
				
				summary_header = []
				summary_content = []

				result[0].each do |key, value|
					if key != :header
						summary_header << key.to_s.split('_').map(&:capitalize).join(' ')
						summary_content << value						
					end
				end
				
				r.addHeader summary_header, :Summary
				r.addData :temp, summary_content, :Summary

				
				r.addHeader ['Result'] + result[0][:header], :Detail
				result[1].each_with_index do |ret, idx|
					pass_fail = ret.last ? "Pass" : "Fail"
					r.addData :"expected#{idx}", ["Expected: #{pass_fail}"] + ret[0, (ret.size - 1) / 2], :Detail
					r.addData :"actual#{idx}", ["Actual: #{pass_fail}"] + ret[(ret.size - 1) / 2, (ret.size - 1) / 2], :Detail					
				end

				r.generate 'Detail_' + Time.now.strftime("%H%M%S"), '.'
			end

		end

	end

end