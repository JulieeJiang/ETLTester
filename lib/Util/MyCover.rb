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
			def getBlock codeBefore, codeAfter
				finalResult = []
				codeAfter[@file].each_index do |i|
					if codeAfter[@file][i] == nil
						finalResult[i] = nil
					else
						finalResult[i] = codeAfter[@file][i] - codeBefore[@file][i]
					end
				end
				finalResult
			end
			# def getLine finalResult
			# 	line = []
			# 	arr = IO.readlines(@file)   
			# 	arr.each_index do |i|
			# 		if arr[i].lstrip.start_with? "m " and arr[i].rstrip.end_with? "do"
			# 			j = i + 1
			# 			while !(arr[j].lstrip.start_with? "m ") and j < arr.length - 1 
			# 				if finalResult[j] == 0 
			# 					line << [j+1, arr[j]]
			# 				end
			# 				j += 1
			# 			end
			# 		end
			# 	end
			# 	line
			# end

			def getLine finalResult
				line = {}
				tempParam = []
				arr = IO.readlines(@file)   
				arr.each_index do |i|
					 if arr[i].lstrip.start_with? 'm ' and arr[i].rstrip.end_with? ' do' 
						tempParam << arr[i].lstrip.rstrip.gsub('m ','').gsub(' do','')
						j = i + 1
						while tempParam.length != 0
						    keyWord = getKeyWord arr[j]
							if keyWord == 'end'
								tempParam.pop
							else 
								if keyWord != nil
								   tempParam << keyWord
								else
									if finalResult[j] == 0 
										if line[tempParam[0]] == nil
											line[tempParam[0]] = []
										end
								      	    line[tempParam[0]] << [j+1, arr[j]]
								    end
								end
							end
							j += 1
						end
					end
				end
				line
			end

			def getKeyWord line
				case 
				when (line.lstrip.start_with? 'if')
				 	 'if'
				when (line.lstrip.start_with? 'case')
					 'case'
				when (line.lstrip.start_with? 'while')
					 'while'
				when (line.lstrip.start_with? 'end')
					 'end'
				end
			end	
		end
	end

end
