module ETLTester

	module Util

		module Assistant

			# Create a new ETL testing project by given path
			def self.new_project project_name, path
				path = "#{path}/" if path !~ /\/^$/
				project_dir = "#{path}#{project_name}"
				raise StandError.new("#{project_dir} is already existed.") if Dir.exist?(project_dir)
				Dir.mkdir("#{project_dir}")

				# Folder used for store test cases
				Dir.mkdir("#{project_dir}/mappings")
				# Folder used for store config.yaml
				Dir.mkdir("#{project_dir}/configuration")
				
				# Set default value.
				File.open("#{project_dir}/configuration/config.yaml", 'w') do |file|
					file.puts %Q{---
# Project path
:Project_Home: #{project_dir}
# The max amount of sql returns.
:MAX_ROW: 50000
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

				
				Dir.mkdir("#{project_dir}/logs")

				Dir.mkdir("#{project_dir}/reports")
			end

		end

	end

end