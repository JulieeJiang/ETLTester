$LOAD_PATH.unshift(__dir__) unless $LOAD_PATH.include?(__dir__)

Dir.new(__dir__).each do |d|
	if Dir.exist?("#{__dir__}/#{d}") && d != ".."  && d != "."
		Dir.new("#{__dir__}/#{d}").grep(/\.rb$/) {|f| require "#{d}/#{f}"}
	end
end