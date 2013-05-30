require '../../lib/etltester'

ETLTester::Util::Configuration.set_project_path File.dirname(File.realpath(__FILE__)) + '/../test project/'
driver = ETLTester::Framework::Driver.new

require './l3_srvr_d'
require './l3_srvr_patch_dtl_f'
require './l3_srvr_patch_dtl_f1'
require './l3_srvr_patch_dtl_f2'
require './l3_srvr_patch_dtl_f3'

ETLTester::Core::Mapping.mappings.each do |mapping|
	driver.mapping = mapping
	puts mapping.mapping_name
	driver.run
end