require '../../lib/etltester'


ETLTester::Framework::setup

executor = ETLTester::Framework::Executor.new 'demo'

executor.execute