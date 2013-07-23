module ETLTester

	module Util

		# Usage:
	   # r = MappingReporter.new
	   # # Create Detail HTML
	   # r.addHeader ["Mapping Name", "Target Records","Source Records","Pass Num", "Failed Num", "Pass Percentage", "Time Cost","Code Coverage"],'Summary'
	   # r.addHeader ['Target Column Name','Target Value', 'Source Value'],'Detail'

	   # r.addText 'Description',%Q{
	   # 	This is description in the text.
	   # }

	   # r.addText 'Warning',%Q{
	   # 	This is warning in the text.
	   # }

	   # r.addData 'Target Table 1',['Target Table 1','10000','10000','5000','5000','100%','20','Fail'],'Summary'
	   # r.addData '1', ['Target1.Column1', '12','365'],'Detail'
	   # r.addData '2', ['Target1.Column2', 'month','year'],'Detail'
	   # r.generate 'Data_detail', "#{File.dirname(File.expand_path(__FILE__))}/../../Report"

	   # # Create Summary HTML
	   # r.clearData
	   # r.addHeader ["Mapping Name", "Target Records","Source Records","Pass Num", "Failed Num", "Pass Percentage", "Time Cost","Code Coverage"]
	   # r.addData 'Target Table 1',['Target Table 1','10000','10000','5000','5000','100%','20','Fail']
	   # r.addLink 'Target Table 1',{4=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Data_detail.html",8=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Coverage_detail.html"}
	   # r.addData 'Target Table 2',['Target Table 2','10000','10000','9999','1','100%','20','Fail']
	   # r.addLink 'Target Table 2',{5=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Data_detail.html",8=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Coverage_detail.html"}
	   # r.addData 'Target Table 3',['Target Table 3','10000','10000','10000','0','100%','20','true']
	   # r.generate 'Summary_test', "#{File.dirname(File.expand_path(__FILE__))}/../../Report"

		class MappingReporter
		
			def initialize
				@headers = {}
				@datas = {}
				@links = {}
				@textArea = {}
			end
			
			def addHeader header, tableName = 'Summary'      # exmpale: setHeader ['column1','column2']
				@headers[tableName] = header
			end
			
			def addData key, data,tableName = 'Summary'    # exmpale: addData 'key1', ['abc', 'def']	
				if  @datas[tableName] == nil
				    @datas[tableName] = {}
				end
				@datas[tableName][key] = data
			end

			def addLink key, link,tableName = 'Summary'     # exmpale: addLink 'key1', {1=>'c:/xx.html'}	
				if  @links[tableName] == nil
				    @links[tableName] = {}
				end
				@links[tableName][key] = link
			end

			def addText key, text     # exmpale: addLink 'Item', 'Context'
				@textArea[key] = text
			end

			def clearData
				@headers.clear
				@textArea.clear
				@datas.clear
				@links.clear
			end

			def generate report_name, dir  # example: generate 'report_name', 'Dir name'  Framework must make sure the dir exists.
				File.open(dir+"/#{report_name}.html", 'w+') do |file|
					file.puts %Q{
					<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
						<html xmlns="http://www.w3.org/1999/xhtml">
						<head>
						<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
						<link href="CSS.css" rel="stylesheet" type="text/css">
						<style type="text/css">
						.container .content table {
							font-family: "HP Simplified", "HPFutura Book", "HPFutura Heavy";
						}
						</style>
						<title>#{report_name}</title>
						<body>
						<div style='float:right'>
							<a href="https://github.com/piecehealth/ETLTester">
								<img src="logo.jpg" alt="" name="Insert_logo" id="Insert_logo" style="background-color: #C6D580; display:block;" />
							</a>
							</div>
						<div class="container" >
							
						  <div class="content">
	 	 				}
	 	 				@textArea.each do |k,item|
	 	 					file.puts %Q{
	 	 					<h1>#{k}</h1>
	 	 					<h5>#{item}</h5>
	 	 					}
	  	 				end

	  	 			@headers.each do |tableName,header|
						file.puts %Q{
						    <h1>#{tableName}</h1>
						       <table  class="table" style="margin:5px">
						    	<tr class="tableheader">
						    }
	    				header.each do |item|
						    	file.puts %Q{	    		
						    		   <th>#{item}</th>
						    	}
						end  
						file.puts %Q{	    		
						    		</tr>
						    		<tr>
						    	}

						i = 0
						if @datas[tableName] != nil
							@datas[tableName].each do |k, item|
								css = i % 2 == 1 ? "tdcss1" : "tdcss2"
								item.each_with_index do |subItem, j|
									if @links[tableName] == nil or @links[tableName][k] == nil or @links[tableName][k][j+1] == nil
										file.puts %Q{
										<td class="#{css}">#{item[j]}</td>		
										}
									else
										file.puts %Q{
										<td class="#{css}"><a href=#{@links[tableName][k][j+1]}><font color="red">#{item[j]}</font></a></td>
										}
									end
								end
								file.puts %Q{
								</tr>
								}
								i += 1
							end    	
						end
						file.puts %Q{
	  							</table>
						}
	  	 		    end
					file.puts %Q{
						    <p>&nbsp;</p>
						    <!-- end .content --></div>
						  <div class="footer">
						    <p><span class="foot"><a href='https://github.com/piecehealth/ETLTester'>ETLTester Home: https://github.com/piecehealth/ETLTester</a></span></p>
						    <!-- end .footer --></div>
							<!-- end .container --></div>
						</body>
						</html>
					}
				end
			end	
		end

	end

end




