require '../../lib/etltester'



mapping("test") do

	# declare used table
	declare_source_table('source1', 's1')
	declare_source_table('source2', 's2')	
	declare_source_table('select * from source3', 's3')	
	declare_cte_as('select * from source4', 's4')
	declare_source_table('source5', 's5')
	declare_source_table('source6', 's6')	

	declare_target_table('target', 't')

	
	# define mapping
	m t.abc, s1.abc
	m t.bbb do
		link s2, "s1.abc = s2.abc"
		s2.ccc
		if s2.bbb > 90
			s2.ccc
		else
			s2.ddd
		end
	end
	m t.ddd do
		link s2, "s1.abc = s2.abc"
		s2.ddd
	end
	m t.ccc do
		link s3, "s1.asd = s3.asd"
		s3.ccc
	end
	m t.ddd do
		lookup(s4, "s1.asd = s3.asd").left_join(s5, "s4.sss = s5.xxx").left_join(s6, "s5.asd = s6.xxx")
		s6.asdd
	end

	puts @source_sql_generator.generate_sql
	puts @source_sql_generator.generate_count_sql
	#puts @source_sql_generator.sql_for_count
	#puts @target_sql_generator.generate_sql
end