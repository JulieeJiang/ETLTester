module ETLTester

	module Util

		class Timer

			def initialize
				@logs = []
			end

			def record description
				@time = Time.now
				if @pre_time.nil?
					msg = "#{@time.strftime("%D-%H:%M:%S")}\t#{description}"
					puts msg
					@logs << msg 
				else
					@spend_time = (@time - @pre_time).round(2)
					msg = "#{@time.strftime("%D-%H:%M:%S")}\t#{description}\tElapsed: #{@spend_time} Seconds."
					puts msg
					@logs << msg
				end
				@pre_time = Time.now
			end

			def transaction_start
				raise StandError.new('Some transcation doesn\'t find transcation_end') if !@transaction_start_time.nil?
				@transaction_start_time = Time.now
			end

			def transaction_end
				elapsed_time = (Time.now - @transaction_start_time).round(2)
				@transaction_start_time = nil
				elapsed_time
			end

			def show_msg msg
				puts msg
				@logs << msg
			end

			def generate_log log_file
				File.open(log_file, 'w') {|f| @logs.each {|log_item| f.puts log_item}}
			end

			attr_reader :spend_time

		end

	end

end