module ETLTester

	module Util

		class Parameter


			def initialize(mapping_name)
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