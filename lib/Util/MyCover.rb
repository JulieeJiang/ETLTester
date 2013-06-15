require "coverage.so" 
module ETLTester

	module Util
		class Node
			attr_accessor :keyWord, :exclude, :subNodes, :isCovered,:parentNode,:line,:detailRow
			@@totalBranch = 0
			@@coveredBranch = 0
			@@uncoveredDetail = []
			
			def initialize keyWord, exclude,line,detailRow
				@keyWord = keyWord
				@exclude = exclude
				@line = line
				@detailRow = detailRow
				@subNodes = []
				@isCovered = true
			end
		end
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
								popKeyWord tempParam
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
			def getLineByMap finalResult
				result = {}
				result[:coverage]=[]
				result[:coverageDetail]={}
				keyWordParam = []
				arr = IO.readlines(@file)   
				arr.each_index do |i|
					if isMap arr[i] 
					 	mName = arr[i].lstrip.rstrip.gsub(' do','').gsub(' #exclude','').gsub('m ','')
						keyWordParam << mName
						rootNode = Node.new mName, isExcluded(arr[i]), i+1, arr[i]
						currNode = rootNode
						j = i + 1
						while keyWordParam.length != 0
						    keyWord = getKeyWord arr[j]
							if keyWord == 'end'
								currNode = currNode.parentNode
								if currNode != nil and currNode.keyWord == 'case'
									currNode = currNode.parentNode # pop to the parentNode of Case
								end
								popKeyWord keyWordParam
							elsif keyWord == 'else' or keyWord == 'elsif' or (keyWord == 'when' and currNode.keyWord == 'when')
								keyWordParam << keyWord
							    node = Node.new keyWord, isExcluded(arr[j]), j+1, arr[j]
							    node.parentNode = currNode.parentNode
							    currNode.parentNode.subNodes<<node
							    currNode = node
					     	elsif keyWord != nil
							    keyWordParam << keyWord
							    node = Node.new keyWord, isExcluded(arr[j]), j+1, arr[j]
							    node.parentNode = currNode
							    currNode.subNodes<<node
							    currNode = node
							else
								if finalResult[j] == 0 
									currNode.isCovered = false
								end
							end
							j += 1
						end
						@@totalBranch = 0
						@@coveredBranch = 0	
						@@uncoveredDetail = []
						printKeyWord rootNode
						if @@totalBranch !=0 
							result[:coverage] << [mName,  @@totalBranch, @@coveredBranch, @@coveredBranch*100/@@totalBranch]
						else
							result[:coverage] << [mName,  @@totalBranch, @@coveredBranch, 100]
						end
						if @@uncoveredDetail.length >0
							result[:coverageDetail][mName] = @@uncoveredDetail
						end
						
					end
				end
				total = 0
				result[:coverage].each do |i|
					total += i[3]
				end
				result[:coveragePer] = total/result[:coverage].length
				result
			end

			def printKeyWord node
			if !node.exclude
					if node.subNodes.length == 0
						@@totalBranch += 1
						if node.isCovered
						@@coveredBranch += 1
						else
						@@uncoveredDetail << [node.line,node.detailRow]
						end
					end
					node.subNodes.each do |item|
						printKeyWord item
					end
				end
			end
			def isMap line
				line = line.rstrip.downcase
				if line.lstrip.start_with? 'm ' and (line.rstrip.end_with? ' do' or line.rstrip.end_with? ' do #exclude' or line.rstrip.end_with? ' do #exclude')
					true
				else
					false
				end
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
				when (line.lstrip.start_with? 'else')
					 'else'
				when (line.lstrip.start_with? 'elsif')
					 'elsif'
				when (line.lstrip.start_with? 'when')
					 'when'
				end
			end	
			def isExcluded line
				line = line.rstrip.downcase
				if line.end_with? 'exclude'
					true
				else
					false
				end
			end	
			def popKeyWord keyWords 
				top = keyWords.pop
				if top == 'when'
					while keyWords.last != 'case'
						keyWords.pop
					end
					keyWords.pop #Pop the corresponding CASE
				elsif top == 'elsif' or top == 'else'
					while keyWords.last != 'if'
						keyWords.pop 
					end
					keyWords.pop #Pop the corresponding IF
				end
			end	
		end
	end
end

