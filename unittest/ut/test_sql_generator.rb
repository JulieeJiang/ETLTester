require '../../lib/etltester'

mapping('test') do

	declare_source_table "select * from asd", :asd
	declare_target_table "select * from t", :t

	mp t.asd, asd.id
	m t.sss, asd.sss

	puts @source_sql_generator.generate_sql
	puts @target_sql_generator.generate_sql

end