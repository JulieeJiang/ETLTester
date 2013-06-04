module ETLTester

	module Framework

		def self.setup
			current_folder = Dir.pwd
			check_folder current_folder
			if Dir.exist? current_folder + "/extension"
				Dir.foreach(current_folder + "/extension") {|f| require("/extension/" + f) if f =~ /\.rb$/}
			end
		end

		private
		# work folder must like below
		# Project folder
		# 	- configuration
		# 		- config.yaml
		def self.check_folder folder
			if Dir.exist?(folder + '/configuration')
				if File.exist?(folder + '/configuration/config.yaml')
					Util::Configuration.set_project_path folder
				else
					raise StandError.new "config.yaml not found!"
				end
			else
				raise StandError.new "Invalid work folder: #{folder}!"
			end
		end

	end

end