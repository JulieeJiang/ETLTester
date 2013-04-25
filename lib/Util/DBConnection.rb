module ETLTester

	module Util
		
		module DBConnection

			# Return a array of hash by the sql_txt.
			# You should install proper database driver.
			# e.g. if db_type is oracle, you should install dbi and ruby-oci8 first.
			def self.get_data_from_db config, sql_txt

				case type = config[:type].downcase.to_sym
					when :oracle
						begin
							require 'dbi'
						rescue LoadError
							raise StandError.new('Install dbi, ruby-oci8 first.(gem install dbi; gem install ruby-oci8)')
						end
						begin
							dbh = DBI.connect("DBI:OCI8:#{config[:address]}", config[:user], config[:password])
							rs = dbh.prepare sql_txt
							rs.execute
							records = []
							rs.fetch_all.each do |r| 
								record = r.to_h
								# Convert data type.
								record.each do |column_name, value|
									if value.class == BigDecimal
										if value.to_i == value
											record[column_name] = value.to_i
										end
									end
								end
								records << record
							end 

							records
						ensure
							dbh.disconnect unless dbh.nil?
						end
					else
						raise UnsupportError.new("Don't support #{type} so far.")
				end
						

			end
			
		end
		
		
	end
	
end