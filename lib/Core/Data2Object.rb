module ETLTester

	module Core

		#                               Main Dataset
		# ----------------------------------------------------------------------
		# | a.col1 a.col2 a.col3 | b.col1 b.col2 b.col3 | c.col1 c.col2 c.col3 |
		# |	 a		  b     c    |	  d	     e       f  |    g      h       i  |
		# |  g        k     l    |    m      n       o  |    p      q       r  |
		# |  s        t     u    |    v      w       x  |    y      z       0  |
		# ----------------------------------------------------------------------
		# |-----SubDataSet1------|-----SubDataSet2------|-----SubDataSet3------|

		def self.create_sub_dataset mapping_runner, dataset_name, *columns
			(class << mapping_runner; self; end).class_eval do
				
			end
		end



		# Generate object to given mapping_runner
		# mapping_runner	: instance of MappingRunner
		# dataset_name		: a meanful name for dataset
		# data 				: return of ETLTester::Util::DBConnection::get_data_from_db
		# sqlgenerate		: instance of SqlGnerate
		def self.data_to_object mapping_runner, dataset_name, data ,sql_generate

			mapping_runner.instance_eval do

				(class << mapping_runner; self; end).class_eval do
					
					if respond_to? dataset_name.to_s.downcase.to_sym
						raise StandError.new("Given dataset name \"#{dataset_name}\" is duplicate with other instance variables, please use another name.")
					end

					class_variable_set("@@#{dataset_name.to_s.downcase}", [])
					
					define_method dataset_name.to_s.downcase.to_sym do
						class_variable_get("@@#{dataset_name.to_s.downcase}")
					end

				end

			end

		end # def self.data_to_object

	end

end