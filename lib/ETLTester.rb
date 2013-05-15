# ETLTester is unit test framework for ETL testing. Developed by HP GITS-DS-CDC BI Testing team.
# It provides a DSL(Domain specific language) to define test case, to improve readablity of test case,
# also provides a more efficency approach to organize & execute test cases.
# Visit https://github.com/piecehealth/ETLTester for more details.

module ETLTester
	$debug = true
end

$LOAD_PATH.unshift(File.dirname(File.realpath(__FILE__))) unless $LOAD_PATH.include?(File.dirname(File.realpath(__FILE__)))

require 'util/timer'
Dir.new(File.dirname(File.realpath(__FILE__))).each do |d|
	if Dir.exist?("#{File.dirname(File.realpath(__FILE__))}/#{d}") && d != ".."  && d != "."
		Dir.new("#{File.dirname(File.realpath(__FILE__))}/#{d}").grep(/\.rb$/) {|f| require "#{d}/#{f}"}
	end
end