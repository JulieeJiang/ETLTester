module ETLTester

	module Util
	
		module GenTestSuite
            # Default settings without filter.
            # generateTestSuite 'testSuite',  'C:/test project',{:report_level=>:smart}
            # Only the directory of first layer will be filtered. 
            # generateTestSuite 'testSuite',  'C:/test project',{:report_level=>:smart},['abc']
            require 'yaml'
			def self.generateTestSuite suiteName, projectDir,parameter,folderDef = []
				@items = {}
				parameter.each do |k,v|
				    @items[k] = v
				end
                if File.directory? projectDir
                    @mappingDir = "#{projectDir}/mappings"
                	@suiteDir = "#{projectDir}/test suite"
                    @mappings = []
                    Dir.foreach(@mappingDir) do |f|
                        if f!='.' and f!= '..' 
                            if File.directory? @mappingDir+'/'+f
                                if folderDef == [] or folderDef.include? f
                                    toMap = []
                                    traverseDir @mappingDir+'/'+f, toMap
                                    @mappings << toMap[0]
                                end
                            else 
                                @mappings << f
                            end
                        end
                    end
                end
                @items[:mappings] = @mappings
				File.open("#{@suiteDir}/#{suiteName}", 'w') { |f| YAML.dump(@items, f) } 
			end

            def self.traverseDir current, mappings
                if File.directory? current
                    newFolder = {}
                    newFolder[(File.basename(current)).to_sym]= []
                    mappings.unshift(newFolder)

                    Dir.foreach(current) do |f|
                        if f!="." and f!=".."
                            traverseDir current+'/'+f,  newFolder[(File.basename(current)).to_sym]
                        end
                    end                           
                else
                    mappings<<File.basename(current)
                end
            end
                                
		end	

	
	end

end