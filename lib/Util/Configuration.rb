module ETLTester

	module Util
	
		module Configuration
			
			require 'yaml'
			def self.set_project_path path
				@@project_path = path
				File.open("#{@@project_path}/configuration/config.yaml", 'a')
			end
			
			def self.load_config config_name
				get_configuration if !class_variable_defined?(:@@configuration)
				@@configuration[config_name]
			end

			def self.set_config config_name, config_body
				get_configuration if !class_variable_defined?(:@@configuration)
				@@configuration[config_name] = config_body
				File.open("#{@@project_path}/configuration/config.yaml", 'w') do |f|
					f.puts @@configuration.to_yaml
				end
			end
			
			private
			def self.get_configuration
				File.open("#{@@project_path}/configuration/config.yaml") do |f|
					if f.size == 0
						@@configuration ||= {}
					else	
						@@configuration = YAML::load(f)
					end
				end
			end
			
		end
	
	end

end