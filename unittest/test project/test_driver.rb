require '../../lib/etltester'

test_mapping = mapping("test_db_container") do

	# declare used table
	declare_source_table(%q{
		select *from itr23.app_d where rownum <= 10
		}, 'app_d')
	declare_source_table('itr23.ci_dtl_f', 'ci')
	
	declare_target_table('test', 't')


	# define mapping
	m t.aaa, app_d.app_ky
	m t.bbb, app_d.app_ci_lgcl_nm
	m t.ccc do
		app_d.inner_join ci, "app_d.app_ci_lgcl_nm = ci.ci_lgcl_nm"
		ci.ci_d_ky
	end
	m t.ddd, ci.dvc_type_ky
	m t.eee do
		app_d.app_ky + ci.ci_d_ky
	end

	#puts @source_sql_generator.generate_sql
	#puts @target_sql_generator.generate_sql
end

ETLTester::Util::Configuration.set_project_path File.dirname(File.realpath(__FILE__))
puts ETLTester::Framework::Driver.new.run_mapping test_mapping