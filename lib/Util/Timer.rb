module ETLTester

	module Util

		class Timer

			def record description
				@time = Time.now
				if @pre_time.nil?
					puts "#{@time.strftime("%D-%H:%M:%S")}\t#{description}"
				else
					@spend_time = (@time - @pre_time).round(2)
					puts "#{@time.strftime("%D-%H:%M:%S")}\t#{description}\tElapsed: #{@spend_time} Seconds."
				end
				@pre_time = Time.now
			end

			attr_reader :spend_time

		end

	end

end