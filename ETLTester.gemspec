# file_list = []
# lib_dir = "#{File.dirname(File.realpath(__FILE__))}/lib"

# file_list << "lib/ETLTester.rb"

# Dir.new(lib_dir).each do |d|
# 	if Dir.exist?("#{lib_dir}/#{d}") && d != ".."  && d != "."
# 		Dir.new("#{lib_dir}/#{d}").grep(/\.rb$/) {|f| file_list << "lib/#{d}/#{f}"}
# 	end
# end

# puts file_list.collect {|file| "'" + file + "'"}.join(",\n")

Gem::Specification.new do |s|

	s.name			= 'ETLTester'
	s.version		= '1.1.4' 
	s.executables 	= ['et'] 
	s.date			= '2013-06-25'
	s.summary		= 'A unittest framework for ETL testing.'
	s.description	= 'Developed by HP GITS-DS-CDC BI Testing team.'
	s.authors 		= ['HP GITS-DS-CDC BI Testing team']
	s.email			= 'kang.zhang@hp.com'
	s.files			= ['lib/ETLTester.rb',
						'lib/Core/Column.rb',
						'lib/Core/DataContainer.rb',
						'lib/Core/Mapping.rb',
						'lib/Core/SqlGenerator.rb',
						'lib/Core/Table.rb',
						'lib/datatype_ext/String.rb',
						'lib/datatype_ext/Time.rb',
						'lib/Framework/Assistant.rb',
						'lib/Framework/cli.rb',
						'lib/Framework/Comparer.rb',
						'lib/Framework/Driver.rb',
						'lib/Framework/Executor.rb',
						'lib/Framework/Setup.rb',
						'lib/Util/Configuration.rb',
						'lib/Util/DBConnection.rb',
						'lib/Util/Error.rb',
						'lib/Util/GenTestSuite.rb',
						'lib/Util/MyCover.rb',
						'lib/Util/Parameter.rb',
						'lib/Util/Reporter.rb',
						'lib/Util/Timer.rb',
						'resource/CSS.css',
						'resource/logo.jpg']
	s.homepage		= 'https://github.com/piecehealth/ETLTester'
	s.licenses = ["MIT"]
end