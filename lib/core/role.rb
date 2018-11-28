require_relative 'recipe'
require_relative 'package'
require_relative 'inspect'
require_relative 'script'

class Role
  include Inspect

  NAME_KEY = 'Name'
  PACKAGES_KEY = 'Packages'
  RECIPES_KEY = 'Recipes'
  SCRIPTS_KEY = 'Scripts'

  attr_reader :scenario, :name, :packages, :recipes, :scripts

  def initialize scenario, hash
    self.name = hash[NAME_KEY]

    package_names = hash[PACKAGES_KEY] || []
    self.packages = package_names.map{ |package_name| Package.new package_name }

    recipe_names = hash[RECIPES_KEY] || []
    self.recipes = recipe_names.map{ |recipe_name| Recipe.for_scenario scenario, recipe_name }

    script_names = hash[SCRIPTS_KEY] || []
    @scripts = script_names.map{ |script_name| Script.for_scenario scenario, script_name }
  end

  def to_h
    {
      NAME_KEY => name,
      PACKAGES_KEY => packages.map{ |package| package.name },
      RECIPES_KEY => recipes.map{ |recipe| recipe.name }
    }
  end

  private

  attr_writer :packages, :recipes

  def name= name
    raise "Role #{NAME_KEY} must not be empty" if name.blank?
    raise "Role #{NAME_KEY} '#{name}' does not only contain alphanumeric characters and underscores" if /\W/.match name
    @name = name
  end

end
