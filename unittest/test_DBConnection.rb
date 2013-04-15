require '../lib/etltester'


ds = ETLTester::Util::DBConnection.get_data_from_db(:oracle, {:tns => "ITR2ITG_DEDICATED", :user_name => "infr", :password => "INFR_INFR_2011.bb"}, "select * from itr23.asset_d aa where rownum <= 10")
puts ds.size
ds[0].each do |k, v|
  puts "#{k}: #{v}, #{v.class}"
end