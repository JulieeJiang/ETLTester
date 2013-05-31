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

			def transaction_start
				raise StandError.new('Some transcation doesn\'t find transcation_end') if !@transaction_start_time.nil?
				@transaction_start_time = Time.now
			end

			def transaction_end
				elapsed_time = (Time.now - @transaction_start_time).round(2)
				@transcation_start_time = nil
				elapsed_time
			end

			attr_reader :spend_time

		end

	end

end