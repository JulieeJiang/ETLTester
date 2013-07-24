class Time

	require 'date'

	# How many months between current Time and given Time(a_time)
	# t1 = Time.new(2013, 5, 20)
	# t2 = Time.new(2012, 7, 21)
	# t1.month_between(t2) # 9.966666666666667
	def month_between a_time
		(self.year - a_time.year) * 12 + self.month - a_time.month + (self.day - a_time.day).to_f / 30
	end

	# Time.new(2013, 5, 20).last_day_of_month # 2013-05-31
	def last_day_of_month
		Date.new(self.year, self.month, -1)
	end

	# Time.new(2013, 5, 20).first_day_of_month # 2013-05-01
	def first_day_of_month
		Date.new(self.year, self.month, 1)
	end

	def tomorrow
		to_date + 1
	end

	def yesterday
		to_date - 1
	end

end