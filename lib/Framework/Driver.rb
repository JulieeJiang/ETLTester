module ETLTester

	module Framework
	
		# Process mapping.
		class Driver

			attr_writer :mapping

			# Return [expected_data, actual_data]
			def run
				db_config = Util::Configuration::get_config :DBConnection
				max_row = Util::Configuration::get_config :MAX_ROW
				dc = Core::DataContainer.new @mapping, db_config, max_row
				result = Comparer.new(dc.expected_data, dc.actual_data, @mapping.source_ignored_items, @mapping.target_ignored_items, dc.warning_list).compare
				#expected_data = ETLTester::Core::DataContainer.new(raw_data, mapping.source_sql_generator).transform(*mapping.mapping_items)
			end

		end

	end

end