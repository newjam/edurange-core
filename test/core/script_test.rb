require_relative '../test_helper.rb'
require 'edurange/core/script'
require 'edurange/core/instance_script'
require 'edurange/core/scenario'
require 'mustache'

class ScriptTest < MiniTest::Test

  def test_script_template
    path = Pathname.new(__dir__) + 'test_script.sh.mustache'
    name = 'test_script'
    script = Script.new(path, name)
    mock_instance = OpenStruct.new(name: 'InstanceName', players: [OpenStruct.new(login: 'james')])
    contents = script.contents_for(mock_instance)
    assert_equal("echo \"InstanceName\"\necho \"james\"\n", contents)
  end

  def test_instance_script
    path = Pathname.new(__dir__) + 'test_script.sh.mustache'
    name = 'test_script'
    script = Script.new(path, name)
    mock_instance = OpenStruct.new(name: 'InstanceName', players: [OpenStruct.new(login: 'james')])

    x = InstanceScript.new(mock_instance, script)
    assert_equal("echo \"InstanceName\"\necho \"james\"\n", x.contents)
  end

  class Foo
    def bar
      42
    end
  end

  # Making sure mustache does what we want.
  def test_mustache_renders_object_with_static_method
    foo = Foo.new
    result = Mustache.render("{{bar}}", foo)
    assert_equal("42", result)
  end

  class Bar
    attr_reader :foo
    def initialize
      @foo = 42
    end
  end

  # Making sure mustache does what we want.
  def test_mustache_renders_object_with_dynamic_method
    bar = Bar.new
    result = Mustache.render("{{foo}}", bar)
    assert_equal("42", result)
  end

  class Baz
    def bars
      [Bar.new, Bar.new]
    end
  end

  # Making sure mustache does what we want.
  def test_mustache_renders_object_with_referenced_object
    baz = Baz.new
    result = Mustache.render("{{#bars}}{{foo}}{{/bars}}", baz)
    assert_equal("4242", result)
  end

  class WithDelegate
    extend Forwardable

    def initialize
      @foo = Foo.new
      @bar = Bar.new
    end

    delegate(:bar => :@foo)
    delegate(:foo => :@bar)

  end

  def test_mustache_renders_delegated_methods
    obj = WithDelegate.new
    result = Mustache.render(">>{{bar}}-{{foo}}<<", obj)
    assert_equal(">>42-42<<", result)
  end

  class InspectOverridden
    def inspect
      return 'hahahaha!'
    end
    def foo
     42
    end
  end

  def test_override_inspect
    obj = InspectOverridden.new
    result = Mustache.render("{{foo}}", obj)
    assert_equal("42", result)
  end

end

