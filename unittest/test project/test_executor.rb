require '../../lib/etltester'


ETLTester::Framework::setup

executor = ETLTester::Framework::Executor.new #'test3'

executor.execute