module ETLTester

	module Framework
	
		class Executor

			def initialize test_suite_name = nil
				if test_suite_name.nil?	# Run all mappings
					@test_suite = {}
					@test_suite[:mappings] = get_all_mappings
					@test_suite[:report_level] = :smart
				else
					test_suite_name = test_suite_name + '.yaml' if test_suite_name !~ /\.yaml$/
					test_suite_yaml = Util::Configuration::get_config(:Project_Home) + "/test suites/" + test_suite_name
					raise StandError.new "Can not find #{test_suite_yaml}." if !File.exist? test_suite_yaml
					require 'yaml'
					File.open(test_suite_yaml) {|f| @test_suite = YAML::load(f)}
				end
			end

			def execute report_folder = Time.now.strftime("%Y%m%d%H%M%S")
				$run_flag = true
				mapping_list.each do |mapping_file|
					require mapping_file
					current_mapping = Core::Mapping.mappings[Core::Mapping.mappings.size - 1]
					if current_mapping.params_flag
						params_file = Util::Configuration::get_config(:Project_Home) + mapping_file.gsub(Util::Configuration::get_config(:Project_Home), '').gsub('/mappings/', '/parameters/').gsub(/\.rb$/, '.yaml')
						current_mapping.params_file = params_file
					end
				end
				driver = ETLTester::Framework::Driver.new
				driver.report_folder = report_folder
				summary_Name = 'Summary_' + Time.now.strftime("%H%M%S")
				driver.summary_name = summary_Name
				
				report_dir = Util::Configuration::get_config(:Project_Home) + '/reports/' + report_folder
				Dir.mkpath(report_dir) if !Dir.exist?(report_dir)
				Dir.mkpath(report_dir + '/details')
				require 'fileutils'

				FileUtils.copy_file(File.dirname(File.realpath(__FILE__)) + '/../../resource/css.css', report_dir + '/css.css')
				FileUtils.copy_file(File.dirname(File.realpath(__FILE__)) + '/../../resource/logo.jpg', report_dir + '/logo.jpg')
				FileUtils.copy_file(File.dirname(File.realpath(__FILE__)) + '/../../resource/css.css', report_dir + '/details/css.css')
				FileUtils.copy_file(File.dirname(File.realpath(__FILE__)) + '/../../resource/logo.jpg', report_dir + '/details/logo.jpg')

				summarys = []	
				$timer ||= Util::Timer.new
				ETLTester::Core::Mapping.mappings.each do |mapping|
					$timer.transaction_start
					driver.mapping = mapping
					begin
						summary = driver.run @test_suite[:report_level]
					rescue
						summary ||= {}
						summary[:result] = 'Error'
						summary[:expected_data_size] = $!.message
						summary[:actual_data_size] = $!.backtrace
						summary[:warning] = ''
						$timer.record "Error:" + $!.message + ". \n" + $!.backtrace.join("\n") 
					end
					summary[:mapping_name] = mapping.mapping_name
					summary[:elapsed] = $timer.transaction_end
					summarys << summary
				end
				
				r = Util::MappingReporter.new				
				summary_header = ['Mapping Name']
				summarys[0].each_key do |key|
					if key != :header && key != :mapping_name && key != :report_name
						summary_header << key.to_s.split('_').map(&:capitalize).join(' ')
					end
				end

				r.addHeader summary_header, :Summary

				summarys.each_with_index do |summary, idx|
					content = [summary[:mapping_name]]
					summary.each do |key, value|
						if key != :header && key != :mapping_name && key != :report_name
							content << value
						end
					end					
					link = {1 => "details/#{summary[:report_name]}.html"}
					r.addData :"temp#{idx}", content, :Summary
					r.addLink :"temp#{idx}", link,:Summary
				end
				Dir.mkpath(report_dir) if !Dir.exist?(report_dir)
				r.generate summary_Name, report_dir
				$timer.show_msg "Done: Report folder: #{report_dir}" 

				if $log_flag
					log_file = Util::Configuration::get_config(:Project_Home) + "/logs/" + summary_Name + '.log'
					$timer.generate_log log_file
				end			
			end


			private
			def get_all_mappings
				mappings_dir = Util::Configuration::get_config(:Project_Home) + "/mappings"
				traverse_dir(mappings_dir)[:mappings]
			end

			def traverse_dir dir
				folders = []
				rb_files = []
				Dir.foreach(dir) do |f|
					if f != '.' && f != '..'
						if File.directory?(dir + '/' + f)
							folders << traverse_dir(dir + '/' + f)
						else
							rb_files << f if f =~ /\.rb$/	
						end
					end
				end
				{File.basename(dir).to_sym => folders + rb_files}
			end

			def mapping_list
				list = []
				@test_suite[:mappings].each do |e|
					if e.kind_of? String
						list << Util::Configuration::get_config(:Project_Home) + "/mappings/#{e}"
					else
						list = list + get_list(e, Util::Configuration::get_config(:Project_Home) + "/mappings/") if e.kind_of? Hash
					end
				end
				list
			end

			def get_list hash, prefix
				list = []
				hash.each do |key, value|
					value.each do |e|
						if e.kind_of? String
							list << (prefix + key.to_s + '/' + e)
						else
							list = list + get_list(e, prefix + key.to_s + '/') if e.kind_of? Hash
						end
					end
				end
				list
			end

		end # class Executor

	end # module Framework

end # module ETLTester