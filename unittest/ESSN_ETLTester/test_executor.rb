require '../../lib/etltester'


ETLTester::Framework::setup

executor = ETLTester::Framework::Executor.new 'alm'

executor.execute