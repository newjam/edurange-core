require 'yaml'
require 'securerandom'
require 'pathname'
require 'ostruct'

# extend object with fancy active support method `blank?`
require 'active_support/core_ext/object/blank'

require_relative 'role'
require_relative 'cloud'
require_relative 'group'
require_relative 'inspect'

class Scenario
  include Inspect

  attr_reader :directory, :name, :description, :instructions, :instructions_student, :roles, :clouds, :groups, :variables

  NAME_KEY = 'Name'
  DESCRIPTION_KEY = 'Description'
  INSTRUCTIONS_KEY = 'Instructions'
  INSTRUCTIONS_STUDENT_KEY = 'InstructionsStudent'
  ROLES_KEY = 'Roles'
  CLOUDS_KEY = 'Clouds'
  GROUPS_KEY = 'Groups'
  VARIABLES_KEY = 'Variables'

  def initialize directory, hash
    self.directory = Pathname.new directory
    self.name = hash[NAME_KEY]
    self.description = hash[DESCRIPTION_KEY]
    self.instructions = hash[INSTRUCTIONS_KEY]
    self.instructions_student = hash[INSTRUCTIONS_STUDENT_KEY]
    role_list = hash[ROLES_KEY] || []
    self.roles = role_list.map{ |role_hash| Role.new self, role_hash }
    cloud_hashes = hash[CLOUDS_KEY] || []
    self.clouds = cloud_hashes.map{ |cloud_hash| Cloud.new self, cloud_hash }
    group_hashes = hash[GROUPS_KEY] || []
    self.groups = group_hashes.map{ |group_hash| Group.from_hash self, group_hash }
    variables_hashes = hash[VARIABLES_KEY] || []
    @variables = OpenStruct.new(Hash[variables_hashes.collect do |var_h|
      var = Variable.from_hash(var_h)
      [var.name, var.value]
    end])
  end

  def self.load_from_yaml_file filename
    path = Pathname.new filename
    hash = YAML.load path.read
    directory = path.dirname
    Scenario.new directory, hash
  end

  def to_h
    {
      NAME_KEY => name,
      DESCRIPTION_KEY => description,
      INSTRUCTIONS_KEY => instructions,
      INSTRUCTIONS_STUDENT_KEY => instructions_student,
      ROLES_KEY => roles.map{ |role| role.to_h },
      CLOUDS_KEY => clouds.map{ |cloud| cloud.to_h },
      GROUPS_KEY => groups.map{ |group| group.to_h }
    }
  end

  def recipes
    instances.flat_map{ |instance| instance.recipes }
  end

  def subnets
    clouds.flat_map{ |cloud| cloud.subnets }
  end

  def instances
    clouds.flat_map{ |cloud| cloud.instances }
  end

  def users
    groups.flat_map{ |group| group.users }
  end

  private :to_h
  private

  def directory= dir
    raise ArgumentError, "Scenario directory '#{dir}' does not exist" unless File.directory?(dir)
    @directory = dir
  end

  def name= name
    raise ArgumentError, "Scenario '#{NAME_KEY}' must not be empty" if name.blank?
    raise ArgumentError, "Scenario '#{NAME_KEY}' can only contain alphanumeric characters and underscores" if /\W/.match name
    @name = name
  end

  def description= description
    raise ArgumentError, "Scenario '#{DESCRIPTION_KEY}' must not be empty" if description.blank?
    @description = description
  end

  def instructions= instructions
    raise ArgumentError, "Scenario '#{INSTRUCTIONS_KEY}' must not be empty" if instructions.blank?
    @instructions = instructions
  end

  def instructions_student= instructions_student
    raise ArgumentError, "Scenario '#{INSTRUCTIONS_STUDENT_KEY}' must not be empty" if instructions_student.blank?
    @instructions_student = instructions_student
  end

  def roles= roles
    raise ArgumentError, "Scenario '#{ROLES_KEY}' must not be empty" if roles.nil?
    @roles = roles
  end

  def clouds= clouds
    raise ArgumentError, "Scenario '#{CLOUDS_KEY}' must not be empty" if clouds.blank?
    @clouds = clouds
  end

  def groups= groups
    raise ArgumentError, "Scenario '#{GROUPS_KEY}' must not be empty" if groups.blank?
    @groups = groups
  end

  # A scenario stored locally given by +name+
  def self.find_by_name name
    self.all.select{ |scenario| scenario.name == name }.first
  end

  # A list of all scenarios stored locally.
  def self.all
    scenarios_dir = Pathname.new('./scenarios')

    ['development', 'production', 'test'].flat_map do |maturity|
      dir = scenarios_dir + maturity
      possible_scenarios = dir.each_child.map do |child|
        child + child.basename.sub_ext('.yml')
      end
      possible_scenarios.select { |path| path.file? }.map { |path| Scenario.load_from_yaml_file path}
    end
  end

end

