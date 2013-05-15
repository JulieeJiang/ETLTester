module ETLTester

	module Util

		class Timer

			def record description
				@time = Time.now
				if @pre_time.nil?
					puts "#{@time.strftime("%D-%H:%M:%S")}\t#{description}"
				else
					puts "#{@time.strftime("%D-%H:%M:%S")}\t#{description}\tSpend: #{(@time - @pre_time).round(2)} Seconds."
				end
				@pre_time = Time.now
			end

		end

	end

end