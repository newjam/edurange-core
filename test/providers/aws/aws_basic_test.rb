require_relative '../basic_scenario_test_base'
require 'edurange/providers/aws'

class AWSBasicScenarioTest < Minitest::Test
  include BasicScenarioTestBase

  def provider
    EDURange::AWS
  end

end

