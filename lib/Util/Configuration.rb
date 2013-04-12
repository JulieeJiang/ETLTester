module ETLTester

	module Util
	
		module Configuration
			require 'yaml'
			def self.set_project_path path
				@@project_path = path
			end
			
			def self.load_config config_item
				
			end
			
			def self.get_configuration
				File.open("#{@@project_path}/configuration/config.yaml", 'a') do |f|
					#@@configuration = YAML
				end
			end
			
			
		end
		Configuration.set_project_path 'C:\Users\zhangkan\Documents\GitHub\ETLTester\unittest\test project'
		Configuration.get_configuration
	
	end

end