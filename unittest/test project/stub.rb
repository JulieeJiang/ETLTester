require '../../lib/etltester'

ETLTester::Util::Configuration.set_project_path File.dirname(File.realpath(__FILE__)) + '/../test project/'
driver = ETLTester::Framework::Driver.new

require './mappings/l3_srvr_d'
require './mappings/l3_srvr_patch_dtl_f'

ObjectSpace.each_object(ETLTester::Core::Mapping) do |mapping|
	driver.mapping = mapping
	driver.run
end