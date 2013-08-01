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