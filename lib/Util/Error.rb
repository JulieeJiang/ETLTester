module ETLTester
	
	def self.generate_error error_type
		if !const_defined?(error_type.to_s.capitalize.to_sym)
			const_set(error_type.to_sym, Class.new(Exception))
		else
			const_get(error_type.to_sym)
		end
	end

	generate_error('SqlGeneratorError')
	generate_error('UsageError')
	generate_error('UnsupportError')
	generate_error('StandError')

end