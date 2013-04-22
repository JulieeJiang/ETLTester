require '../../lib/etltester'



mapping("test") do

	# declare used table
	declare_source_table('source1', 's1')
	declare_source_table('source2', 's2')	
	declare_source_table('select * from source3', 's3')	

	declare_target_table('target', 't')	

	
	# define mapping
	m t.abc, s1.abc
	m t.bbb do
		s1.inner_join s2, "s1.abc = s2.abc"
		if s2.bbb > 90
			s2.ccc
		else
			s2.ddd
		end
	end

	puts @source_sql_generator.generate_sql
	puts @target_sql_generator.generate_sql
end