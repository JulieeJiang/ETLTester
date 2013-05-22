class String

	# Convert string to time.
	# Example: '2012-5-22'.to_time => 2012-05-22 00:00:00 +0800
	# 			'2012/5/22'.to_time('/') => 2012-05-22 00:00:00 +0800
	def to_time delimiter = '-'
		ymd = self.split(delimiter)
		Time.new(ymd[0], ymd[1], ymd[2])
	end

end