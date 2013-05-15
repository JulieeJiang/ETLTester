module ETLTester

	module Util
		
		module DBConnection

			# Return a array the sql_txt.
			# You should install proper database driver.
			# e.g. if db_type is oracle, you should install ruby-oci8 first.
			def self.get_data_from_db config, sql_txt

				case type = config[:type].downcase.to_sym
					when :oracle
						begin
							require 'oci8'
						rescue LoadError
							raise StandError.new('Install ruby-oci8 first.(gem install ruby-oci8)')
						end
						oci = OCI8.new(config[:user], config[:password], config[:address])
						oci.prefetch_rows = 15000
						records = []
						oci.exec(sql_txt) do |record|
							# Convert data type.
							records << record.collect do |i|
								if i.class == BigDecimal
									if i.to_i == i
										next i.to_i
									end
								end
								i
							end
						end
						return records						
					else
						raise UnsupportError.new("Don't support #{type} so far.")
				end			

			end

			def self.get_transformed_data config, sql_txt, &transformation

				case type = config[:type].downcase.to_sym
					when :oracle
						begin
							require 'oci8'
						rescue LoadError
							raise StandError.new('Install ruby-oci8 first.(gem install ruby-oci8)')
						end
						oci = OCI8.new(config[:user], config[:password], config[:address])
						oci.prefetch_rows = 15000
						oci.exec(sql_txt) do |record|
							# Convert data type.
							yield(record.collect do |i|
								if i.class == BigDecimal
									if i.to_i == i
										next i.to_i
									end
								end
								i
							end)
						end					
					else
						raise UnsupportError.new("Don't support #{type} so far.")
				end			

			end
			
		end
		
		
	end
	
end