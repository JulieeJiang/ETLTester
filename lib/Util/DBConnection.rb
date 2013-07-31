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
						raise StandError.new('You should install ruby-oci8.(gem install ruby-oci8)')
					end
					oci = OCI8.new(config[:user], config[:password], config[:address])
					oci.prefetch_rows = 15000
					records = []
					require 'bigdecimal'
					oci.exec(sql_txt) do |record|
						records << record.collect do |i|
							if i.kind_of? BigDecimal
								if i.to_i == i
									next i.to_i
								end
							end
							i
						end
					end
					return records						
				when :sql_server
					begin
						require 'tiny_tds'
					rescue LoadError
						raise StandError.new('You should install tiny_tds.(gem install tiny_tds)')
					end
					config.delete :sql_server
					client = TinyTds::Client.new config
					begin
						return client.execute(sql_txt).to_a.map(&:values)
					ensure
						client.close
					end
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
						raise StandError.new('You should install ruby-oci8.(gem install ruby-oci8)')
					end
					oci = OCI8.new(config[:user], config[:password], config[:address])
					require 'bigdecimal'
					oci.prefetch_rows = 15000
					oci.exec(sql_txt) do |record|
						# Convert data type.
						yield(record.collect do |i|
							if i.kind_of? BigDecimal
								if i.to_i == i
									next i.to_i
								end
							end
							next DBNil.new if i.nil?
							i
						end)
					end					
				when :sql_server
					begin
						require 'tiny_tds'
					rescue LoadError
						raise StandError.new('You should install tiny_tds.(gem install tiny_tds)')
					end
					config.delete :sql_server
					client = TinyTds::Client.new config
					begin
						client.execute(sql_txt).to_a.map(&:values).each do |record|
							yield(record.map {|col| col.nil? ? DBNil.new : col})
						end
					ensure
						client.close
					end
				else
					raise UnsupportError.new("Don't support #{type} so far.")
				end			

			end
			
			class DBNil
				
				def nil?
					true
				end
				
				def == obj
					if obj == nil
						true
					else
						false
					end
				end


				alias_method :original_method_missing, :method_missing
				
				def method_missing method_name, *args, &blk
					require 'date'
					case 
					when String.instance_methods.include?(method_name)
						add_method method_name
						DBNil.new
					when Fixnum.instance_methods.include?(method_name)
						add_method method_name
						DBNil.new
					when Float.instance_methods.include?(method_name)
						add_method method_name
						DBNil.new
					when Time.instance_methods.include?(method_name)
						add_method method_name
						DBNil.new
					when Date.instance_methods.include?(method_name)
						add_method method_name
						DBNil.new
					else
						original_method_missing method_name, *args, &blk
					end
				end

				def to_s
					'<NULL in DB>'
				end
				
				private
				def add_method method_name
					self.class.class_eval do
						define_method method_name do |*args, &blk|
							return self.class.new
						end
					end
				end
			end

		end
		
	end
	
end