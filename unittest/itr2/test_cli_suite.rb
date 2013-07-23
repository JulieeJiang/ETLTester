require '../../lib/etltester'

cli = ETLTester::Framework::Cli.new

# cli.respond 'suite'
# cli.respond 'suite', 'release22'
cli.respond 'run'