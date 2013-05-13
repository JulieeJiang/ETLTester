require '../../../../lib/etltester'

test_mapping = mapping("test_variable") do

	# declare used table
	declare_source_table("itr23.app_d", 'app_d')
	declare_source_table('itr23.ci_dtl_f', 'ci')
	
	declare_target_table('test', 't')


	define_global_variable(:test) {2000}
	define_global_variable(:row_num) {20}
	define_row_variable(:app_ky) {app_d.app_ky}

	# define mapping
	m t.aaa, app_d.app_ky
	m t.bbb, app_d.app_ci_lgcl_nm
	m t.ccc do
		app_d.inner_join ci, "app_d.app_ci_lgcl_nm = ci.ci_lgcl_nm"
		ci.ci_d_ky
	end
	m t.ddd, ci.dvc_type_ky
	m t.eee do
		if app_d.app_ky < global_variables[:test]
			'Yes, you get me!'
		else
			ci.ci_d_ky
		end
	end

	m t.fff do
		puts app_d.app_ky.class
		puts row_variables[:app_ky].class
		if app_d.app_ky == row_variables[:app_ky]
			'Nice!'
		else
			'Oops'
		end
	end

	#source_filter
	set_source_filter {"rownum <= #{global_variables[:row_num]}"}

end

dc = ETLTester::Core::DataContainer.new test_mapping, 
	{type: :oracle, address: "ITR2ITG_DEDICATED", user: "infr", password: "INFR_INFR_2011.bb"}
expected_data = dc.transform *test_mapping.mapping_items

expected_data.each do |value|
	puts value
end
