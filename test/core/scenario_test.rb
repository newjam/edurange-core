
require_relative '../test_helper'

require 'edurange/core/scenario'
require 'pathname'
require 'yaml'

class ScenarioTest < Minitest::Test

  attr_reader :directory, :hash

  BASIC_FILENAME = './scenarios/test/basic/basic.yml'

  def setup
    path = Pathname.new BASIC_FILENAME
    @directory = path.dirname
    @hash = YAML.load path.read
  end

  def test_basic_valid
    Scenario.load_from_yaml_file BASIC_FILENAME
  end

  def test_scenario_name_required
    hash.delete(Scenario::NAME_KEY)
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end
  end

  def test_scenario_name_not_nil
    hash[Scenario::NAME_KEY] = nil
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end
  end

  def test_scenario_name_valid_characters
    hash[Scenario::NAME_KEY] = '%wat!'
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end
  end

  def test_directory_must_exist
    bad_directory = Pathname.new '/this/directory/probably/does/not/exists'
    assert_raises ArgumentError do
      Scenario.new bad_directory, hash
    end
  end

  def test_cloud_ip_valid
    hash[Scenario::CLOUDS_KEY].each do |cloud_hash|
      cloud_hash[Cloud::CIDR_BLOCK_KEY] = '666.666.666.666'
   end
   assert_raises ArgumentError do
     Scenario.new directory, hash
   end
  end

  def test_subnet_cidr_block_valid
    hash[Scenario::CLOUDS_KEY].first[Cloud::SUBNETS_KEY].first[Subnet::CIDR_BLOCK_KEY] = '0.0.0.0'
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end

    hash[Scenario::CLOUDS_KEY].first[Cloud::SUBNETS_KEY].first[Subnet::CIDR_BLOCK_KEY] = '2001:db8::ff00:42:8329/24'
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end

    hash[Scenario::CLOUDS_KEY].first[Cloud::SUBNETS_KEY].first[Subnet::CIDR_BLOCK_KEY] = '10.0.1.0/24'
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end
  end

  def test_bad_instance_access_reference
    hash[Scenario::GROUPS_KEY].first[Group::ACCESS_KEY].first[Access::INSTANCE_KEY] = 'ObviouslyNotTheRightName'
    assert_raises ArgumentError do
      Scenario.new directory, hash
    end
  end

  def test_players
    scenario = Scenario.new(directory, hash)
    user = scenario.users.first
    assert_equal('james', user.login)
    assert_equal('s00p3rs3cr37', user.password.to_s)
  end

  def test_users_variable_set
    scenario = Scenario.new(directory, hash)
    user = scenario.users.first
    assert(!user.variables.flag.nil?)
  end

  def test_instance_references
    scenario = Scenario.new(directory, hash)
    instance = scenario.instances.first
    assert_equal(2, instance.roles.size) # TODO: there is only 1 role for this instance in the definition, but we add an 'implicit' role to set up edurange specific things. This is confusing, though, and maybe adding this implicit role should be done outside of the configuration core.
    assert_equal(2, instance.scripts.size)
    assert_equal(1, instance.users.size)


    script = instance.scripts.first

    role = instance.roles.first
    assert_equal(1, role.scripts.size)
  end

  def test_scenario_references
    scenario = Scenario.new(directory, hash)
    assert_respond_to(scenario, :subnets)
    assert_equal(1, scenario.subnets.size)
  end

  def test_script_templating
    scenario = Scenario.new(directory, hash)
    instance = scenario.instances.first
    script = instance.scripts.first

    actual = script.contents_for(instance)
    assert(actual.include? 'useradd')
    assert(actual.include? '--home-dir /home/james')
  end

  def test_wtf
    scenario = Scenario.new(directory, hash)
    instance = scenario.instances.first
    actual = Mustache.render("{{name}}", instance)
    assert_equal(instance.name, actual)
  end

  def test_find_all
    Scenario.all
  end

  def test_find_by_name
    scenario = Scenario.find_by_name 'Barebones'
    assert scenario
    assert_equal 'Barebones', scenario.name

    non_scenario = Scenario.find_by_name 'ImprobableScenarioName'
    assert non_scenario.nil?

  end

  def test_user_variable
    scenario = Scenario.find_by_name 'Barebones'
    user = scenario.users.first
    a = user.variables.flag
    b = user.variables.flag
    assert_equal(a, b)

  end

end

