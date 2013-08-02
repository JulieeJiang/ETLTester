def parse_excel work_book_path, work_sheet_index
	require 'win32ole'
	workbook = WIN32OLE::new('excel.Application').workbooks.open(work_book_path)
	worksheet = workbook.worksheets work_sheet_index
	data, headers = [], []
	worksheet.usedrange.value.each_with_index do |row, i|
		if i == 0
			headers = row
		else
			d = {}
			headers.each_with_index do |header, j|
				d[header] = row[j]
			end
			data << d
		end
	end
	data
ensure
	workbook.close(1) unless workbook.nil?
end

# data = parse_excel 'C:\GitHub\ETLTester (GitHub for Windows)\unittest\ESSN_ETLTester\doc\2013 07 30_HPN Workflow_Mapping to GF_2013_v4.xlsx', 2
# map = {}
# data.select {|r| r["ESSN Column Name"] == 'State'}.each {|r| map[r['SRC Value']] = r['ESSN Value'] if r['SRC Label'].split('/').size == 2}
# puts map