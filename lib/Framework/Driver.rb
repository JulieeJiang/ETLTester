module ETLTester

	module Framework
	
		# Process mapping.
		class Driver
		
			# Return [expected_data, actual_data]
			def run_mapping mapping 
				db_config = ETLTester::Util::Configuration::get_config :DBConnection
				puts db_config
				raw_data = ETLTester::Util::DBConnection::get_data_from_db(db_config, mapping.source_sql_generator.generate_sql)
				expected_data = ETLTester::Core::DataContainer.new(raw_data, mapping.source_sql_generator).transform(*mapping.mapping_items)
			end

		end

	end

end