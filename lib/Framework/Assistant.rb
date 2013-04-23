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
				Configuration::set_project_path project_dir
				Configuration::set_config :MAX_ROW, 50000

				
				Dir.mkdir("#{project_dir}/logs")

				Dir.mkdir("#{project_dir}/reports")
			end

		end

	end

end