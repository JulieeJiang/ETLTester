module ETLTester

	module Framework

		# Command line interface.
		class Cli
		
			def initialize
				@current_folder = Dir.pwd
			end

			def respond *args
				first_argument = args[0]
				args.shift
				case first_argument.downcase
				when 'new'
					respond_new *args
				when 'suite'
					
				when 'test'
					
				when 'run'
				
				when 'help'
					puts %Q{---------	ETLTester	---------
# Argment surrounded by angel brackets means it is mandatory, like <your argment>
# Argment surrounded by brackets means it is optional, like [your argment]
* Create new project	: et new project <your project name>
# et new project 'test project'
* Create new mapping 	: et new mapping <your mapping path>
# et new mapping 'release 21/some module/mapping1'
* Create suite 		: et suite [your suite name]
# et suite relase21 or et suite
* Run suite 			: et run [your suite name]
# et run release 21 or et run
* Test mappings		: et test <your mapping path>
# et test 'release 21/some module/mapping1'
---------https://github.com/piecehealth/ETLTester---------}
				else
					puts "Invaild command #{first_argument}, type 'et help' for help..."
				end
			end

			def respond_new *args
				if args[0].downcase == 'project'
					if args[1].nil?
						puts "You must specify a project name."
					else
						Framework::Assistant::new_project args[1], @current_folder
						puts "Successful: new test project: #{@current_folder}/#{args[1]}"
					end
				end
				if args[0].downcase == 'mapping'
					msg = check_work_space
					if msg.empty?
						if args[1].nil?
							puts "You must specify a mapping path. e.g. et new mapping 'release 21/some module/mapping1'."
						else
							arr = args[1].split('/')
							mapping_name = arr.last
							arr.delete_at(arr.size - 1)
							mapping_folder = arr.join('/')
							Framework::Assistant::new_mapping mapping_name, @current_folder + "/mappings/" + mapping_folder
							puts "Successful: new mapping: #{@current_folder}/mappings/#{mapping_folder}/#{args[1]}"
						end
					else
						puts msg
					end
				end
			end


			private
			def check_work_space
				msg = ''
				if Dir.exist? @current_folder + "/configuration"
					if !File.exist? @current_folder + "/configuration/config.yaml"
						msg = msg + "/configuration/config.yaml not found.\n"
					end
				else
					msg = msg + "/configuration not found.\n"
				end
				msg = msg + check_folder("mappings")
				msg = msg + check_folder("test suites")
			end

			def check_folder folder
				if Dir.exist? @current_folder + "/" + folder
					""
				else
					"/#{folder} not found.\n"
				end
			end

		end

	end

end