require '../../lib/etltester'

test_mapping = mapping("test_db_container") do

	# declare used table
	declare_source_table <<-SQL,'app_d'
		select * from itr23.app_d where rownum <= 10
		SQL
	declare_source_table('itr23.ci_dtl_f', 'ci')
	
	declare_target_table('itr23.app_d', 't')


	# define mapping
	m t.app_ky, app_d.app_ky
	m t.app_ci_lgcl_nm, app_d.app_ci_lgcl_nm
	# m t.app_ky do
	# 	lookup ci, "app_d.app_ci_lgcl_nm = ci.ci_lgcl_nm"
	# 	ci.ci_d_ky
	# end
	# m t.app_ky, ci.dvc_type_ky
	# m t.app_ky do
	# 	app_d.app_ky + ci.ci_d_ky
	# end

	#puts @source_sql_generator.generate_sql
	#puts @target_sql_generator.generate_sql
end

dc = ETLTester::Core::DataContainer.new test_mapping, 
	{type: :oracle, address: "ITR2ITG_DEDICATED", user: "infr", password: "INFR_INFR_2011.bb"}, 10000
dc.transform *test_mapping.mapping_items

dc.expected_data.each_with_index do |value, idx|
	puts "Expected"
	puts value
	puts "Actual"
	puts dc.actual_data[idx]
end