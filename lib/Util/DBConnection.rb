module ETLTester

	module Util
		
		module DBConnection

			def get_data_from_db db_type, config, sql_txt

				case type = db_type.downcase.to_sym
					when :oracle
						require 'dbi'
						begin
							dbh = DBI.connect("DBI:OCI8:#{config[:tns]}", config[:user_name], config[:password])
							rs = dbh.prepare sql_txt
							rs.execute
						ensure
							dbh.disconnect unless dbh.nil?
						end
					else
						raise StandardError("Don't support #{type} so far.")
				end
						

			end
			
		end
		
		
	end
	
end