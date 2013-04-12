require 'yaml'

connection1 = {:tns => 'abc', :password => 'abc', :user => 'abc'}
connection2 = {:tns => 'ccc', :password => 'ccc', :user => 'ddd'}
config = {:db1 => connection1, :db2 =>  connection2}

#~ File.open('sss.yaml', 'w') do |f|
	#~ f.puts connection1.to_yaml
	#~ f.puts connection2.to_yaml
#~ end


File.open('sss.yaml', 'w') do |f|
	f.puts config.to_yaml
end


File.open('sss.yaml') do |f|
	@config = YAML::load(f)
end

puts @config[:db1]