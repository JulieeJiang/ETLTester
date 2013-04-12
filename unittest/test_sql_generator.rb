require '../lib/core/mapping'
require '../lib/core/table'
require '../lib/core/sqlgenerator'
require '../lib/core/column'


mapping("test") do

	# declare used table
	declare_source_table('source1', 's1')
	declare_source_table('source2', 's2')	
	declare_source_table('source3', 's3')	
	
	declare_target_table('target', 't')

	
	# define mapping
	m t.abc, s1.abc
	m t.bbb do
		s1.inner_join s2, "s1.abc = s2.abc"
		if s2.bbb > 90
			s2.ccc
			'A'
		else
			s2.ddd
			'B'
		end
	end
	s2.ccc
	#~ m t.ddd do
		#~ s1.inner_join s2, "s1.abc = s2.abc"
		#~ s2.ddd
	#~ end
	m t.ccc do
		s1.inner_join s3, "s1.asd = s3.asd"
		s3.ccc
	end

	puts @source_sql_generator.generate_sql
	puts @target_sql_generator.generate_sql
end