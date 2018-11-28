require_relative '../basic_scenario_test_base'
require 'providers/docker'
require 'core/scenario'

# Runs the sccenarios/test/basic/basic.yaml scenario
class DockerBasicScenarioTest < Minitest::Test
  include BasicScenarioTestBase

  def provider
    EDURange::Docker
  end

end

