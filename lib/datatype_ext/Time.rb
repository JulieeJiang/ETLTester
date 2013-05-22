class Time

	# How many months between current Time and given Time(a_time)
	# t1 = Time.new(2013, 5, 20)
	# t2 = Time.new(2012, 7, 21)
	# t1.differ_month(t2) # 9.966666666666667
	def month_between a_time
		(self.year - a_time.year) * 12 + self.month - a_time.month + (self.day - a_time.day).to_f / 30
	end

end