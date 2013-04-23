# ETLTester is unit test framework for ETL testing. Developed by HP GITS-DS-CDC BI Testing team.
# It provides a DSL(Domain specific language) to define test case, to improve readablity of test case,
# also provides a more efficency approach to organize & execute test cases.
# Visit https://github.com/piecehealth/ETLTester for more details.

module ETLTester;end

$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

Dir.new(__dir__).each do |d|
	if Dir.exist?("#{__dir__}/#{d}") && d != ".."  && d != "."
		Dir.new("#{__dir__}/#{d}").grep(/\.rb$/) {|f| require "#{d}/#{f}"}
	end
end