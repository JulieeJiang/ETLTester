require "coverage.so" 
module ETLTester

	module Util
		
		class MyCover
			attr_reader :file

			def initialize _file
				@file = _file
			end
			
			def codeStart
				Coverage.start
				load file
			end
			def codeResult 
				Coverage.result
			end
			def getBlock codeResult1, codeResult2
				finalResult = []
				codeResult2[@file].each_index do |i|
					if codeResult2[@file][i] == nil
						finalResult[i] = nil
					else
						finalResult[i] = codeResult2[@file][i] - codeResult1[@file][i]
					end
				end
				finalResult
			end
			def getLine finalResult
				line = []
				arr = IO.readlines(@file)   
				arr.each_index do |i|
					if arr[i].lstrip.start_with? "m " and arr[i].rstrip.end_with? "do"
						j = i + 1
						while !(arr[j].lstrip.start_with? "m ") and j < arr.length - 1 
							if finalResult[j] == 0 
								line << [j+1, arr[j]]
							end
							j += 1
						end
					end
				end
				line
			end
		end
	end

end