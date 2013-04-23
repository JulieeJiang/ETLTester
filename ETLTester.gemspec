# file_list = []
# lib_dir = "#{__dir__}/lib"

# file_list << "lib/ETLTester.rb"

# Dir.new(lib_dir).each do |d|
# 	if Dir.exist?("#{lib_dir}/#{d}") && d != ".."  && d != "."
# 		Dir.new("#{lib_dir}/#{d}").grep(/\.rb$/) {|f| file_list << "lib/#{d}/#{f}"}
# 	end
# end

# puts file_list

Gem::Specification.new do |s|

	s.name			= 'ETLTester'
	s.version		= '0.0.1' 
	s.executables 	= ['et'] 
	s.date			= '2013-04-23'
	s.summary		= 'A unittest framework for ETL testing.'
	s.description	= 'Developed by HP GITS-DS-CDC BI Testing team.'
	s.authors 		= ['HP GITS-DS-CDC BI Testing team']
	s.email			= 'kang.zhang@hp.com'
	s.files			= ["lib/ETLTester.rb", 
						"lib/Core/Column.rb", 
						"lib/Core/DataContainer.rb", 
						"lib/Core/Mapping.rb", 
						"lib/Core/SqlGenerator.rb", 
						"lib/Core/Table.rb", 
						"lib/Framework/Assistant.rb", 
						"lib/Framework/Driver.rb", 
						"lib/Util/Configuration.rb", 
						"lib/Util/DBConnection.rb", 
						"lib/Util/Error.rb",
						"bin/et"]
	s.homepage		= 'https://github.com/piecehealth/ETLTester'
	s.licenses = ["MIT"]
end