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

			def execute
				mapping_list.each do |mapping_file|
					require mapping_file
				end
				driver = ETLTester::Framework::Driver.new
				ETLTester::Core::Mapping.mappings.each do |mapping|
					driver.mapping = mapping
					driver.run @test_suite[:report_level]
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
							folder << traverse_dir(dir + '/' + f)
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