require '../../../../lib/etltester'



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
		s1.inner_join s2, "s1.abc = s2.abc"
		s2.ccc
		if s2.bbb > 90
			s2.ccc
		else
			s2.ddd
		end
	end
	m t.ddd do
		s1.inner_join s2, "s1.abc = s2.abc"
		params[:a]
		s2.ddd
	end
	m t.ccc do
		s1.inner_join s3, "s1.asd = s3.asd"
		s3.ccc
	end
	m t.ddd do
		s1.inner_join(s4, "s1.asd = s3.asd").left_join(s5, "s4.sss = s5.xxx").left_join(s6, "s5.asd = s6.xxx")
		params[:b]
		s6.asdd
	end
end