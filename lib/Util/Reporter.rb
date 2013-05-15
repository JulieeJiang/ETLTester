module TestingTool

	class MappingReporter
	
		def initialize
			@headers = []
			@datas = {}
			@links = {}
		end
		
		def setHeader header      # exmpale: setHeader ['column1','column2']
			@headers = header
		end
		
		def addData key, data     # exmpale: addData 'key1', ['abc', 'def']
			@datas[key] = data
		end

		def addLink key, link     # exmpale: addLink 'key1', {1=>'c:/xx.html'}
			@links[key] = link
		end

		def clearData 
			@datas.clear
			@links.clear
		end

		def generate report_name, dir
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
					<div class="container" >
					  <div class="header"><a href="#"><img src="logo.jpg" alt="" name="Insert_logo" width="52" height="48" id="Insert_logo" style="background-color: #C6D580; display:block;" /></a></div>
					  <div class="content">
					    <h1>#{report_name}</h1>
					    <table  cellpadding=0 cellspacing=0 border=1 width="100%" height="100%" border="1" style="margin:5">
					    	<tr class="tableheader">
					    }
					    @headers.each do |item|
					    	file.puts %Q{	    		
					    		   <th>#{item}</th>
					    		}
					    end     
				
					file.puts %Q{	    		
					    		   </tr>
					    		   <tr>
					    		}
					i = 0
					@datas.each do |k, item|
						css = i % 2 == 1 ? "tdcss1" : "tdcss2"
						item.each_with_index do |subItem, j|
							if @links[k] == nil or @links[k][j+1] == nil
								file.puts %Q{
								<td class="#{css}">#{item[j]}</td>		
								}
							else
								file.puts %Q{
								<td class="#{css}"><a href=#{@links[k][j+1]}><font color="red">#{item[j]}</font></a></td>
								}
							end
						end
						file.puts %Q{
						</tr>
						}
						i += 1
					end
				file.puts %Q{
  					</table>
					    <p>&nbsp;</p>
					    <!-- end .content --></div>
					  <div class="footer">
					    <p><span class="foot"> © Copyright 2013 Hewlett-Packard Development Company, L.P.</span></p>
					    <!-- end .footer --></div>
						<!-- end .container --></div>
					</body>
					</html>
				}
			end
		end	
	end

   r = MappingReporter.new

   r.setHeader ['Line','Command']
   r.addData '1', ['19', 't.abc = 99']
   r.addData '2', ['20', 't.abc']
   r.generate 'Coverage_detail', "#{File.dirname(File.expand_path(__FILE__))}/../../Report"
  
   r.clearData
   r.setHeader ['Target Column Name','Target Value', 'Source Value']
   r.addData '1', ['Target1.Column1', '12','365']
   r.addData '2', ['Target1.Column2', 'month','year']
   r.generate 'Data_detail', "#{File.dirname(File.expand_path(__FILE__))}/../../Report"

   r.clearData
   r.setHeader ["Mapping Name", "Target Records","Source Records","Pass Num", "Failed Num", "Pass Percentage", "Time Cost","Code Coverage", ]
   r.addData 'Target Table 1',['Target Table 1','10000','10000','5000','5000','100%','20','Fail']
   r.addLink 'Target Table 1',{4=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Data_detail.html",8=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Coverage_detail.html"}
   r.addData 'Target Table 2',['Target Table 2','10000','10000','9999','1','100%','20','Fail']
   r.addLink 'Target Table 2',{5=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Data_detail.html",8=>"#{File.dirname(File.expand_path(__FILE__))}/../../Report/Coverage_detail.html"}
   r.addData 'Target Table 3',['Target Table 3','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 4',['Target Table 4','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 5',['Target Table 3','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 6',['Target Table 4','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 7',['Target Table 3','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 8',['Target Table 4','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 9',['Target Table 3','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 10',['Target Table 4','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 11',['Target Table 3','10000','10000','10000','0','100%','20','true']
   r.addData 'Target Table 12',['Target Table 4','10000','10000','10000','0','100%','20','true']
 
   r.generate 'Summary_test', "#{File.dirname(File.expand_path(__FILE__))}/../../Report"


end

