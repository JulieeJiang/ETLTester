module ETLTester

	module Framework

		module Assistant

			# Create a new ETL testing project by given path
			def self.new_project project_name, path
				path = "#{path}/" if path !~ /\/^$/
				project_dir = "#{path}#{project_name}".gsub('//', '/')
				raise StandError.new("#{project_dir} is already existed.") if Dir.exist?(project_dir)
				Dir.mkdir("#{project_dir}")

				# Folder used for store test cases
				Dir.mkdir("#{project_dir}/mappings")
				# Folder used for store config.yaml
				Dir.mkdir("#{project_dir}/configuration")
				# Folder used for store tes suite
				Dir.mkdir("#{project_dir}/test suites")
				# Folder used for store log
				Dir.mkdir("#{project_dir}/logs")
				# Folder used for store reports
				Dir.mkdir("#{project_dir}/reports")

				# Set default value.
				File.open("#{project_dir}/configuration/config.yaml", 'w') do |file|
					file.puts %Q{---
# Project path
:Project_Home: #{project_dir}
# The max amount of sql returns.
:MAX_ROW: 200000
# How to connect database
:DBConnection:
  #	Database type: e.g. oracle, sqlserver, teradata... refer to ETLTester::Util::DBConnection::get_data_from_db
  :type: 
  #	Database address
  :address: 
  #	User for login Database
  :user: 
  #	Password for above user.
  :password: }
				end

			end # sef.new_project


			def self.new_mapping mapping_name, path
				Dir.mkpath(path)
				if File.exist?(path + "/" + mapping_name)
					raise StandError.new "#{path + "/" + mapping_name} is already existed."
				else
					mapping_name = mapping_name.gsub(/\.rb$/, '') if mapping_name =~ /\.rb$/
					File.open(path + "/" + mapping_name + '.rb', 'w') do |f|
						f.puts %Q{require 'etltester'
mapping("#{mapping_name}") do

	# declare table will be used
	#
	# e.g. :
	# declare_target_table 'target_table', :t
	# declare_source_table 'source_table1', :src1
	# declare_source_table "select * from source_table2 where lgcl_del_fg = 'n'", :src2
	# declare_cte_as "select * from source_table3", :src3




	# define mappings
	#
	# e.g. :
	#
	# mp t.pk, src1.pk
	#
	# m t.some_ky, do
	# 	left_join src2, 'src1.fk = src2.pk'
	# 	if src2.some_ky.nil?
	# 		0 # Not Found
	# 	else
	# 		src2.some_ky
	# 	end
	# end


	# Refer to "https://github.com/piecehealth/ETLTester" for more information.

end}
					end
				end
			end

		end

	end

end