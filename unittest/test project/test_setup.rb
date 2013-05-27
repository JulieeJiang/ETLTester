require '../../lib/etltester'


ETLTester::Framework::setup

puts ETLTester::Util::Configuration.get_config :DBConnection