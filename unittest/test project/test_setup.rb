require '../../lib/etltester'


ETLTester::Framework::setup


ETLTester::Util::GenTestSuite::generateTestSuite 'test', ETLTester::Util::Configuration.get_config(:Project_Home), {:report_level=>:smart}