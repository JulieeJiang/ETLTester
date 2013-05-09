module ETLTester

	module Util

		class Parameter


			def initialize
				@param = {}
			end

			def []= key, value
				@param[key] = value
			end

			def [] key
				@param[key]
			end

		end

	end

end