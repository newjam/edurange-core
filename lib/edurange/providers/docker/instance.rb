require 'pathname'
require 'semantic_logger'
require 'json'

require_relative 'instance_image'
require_relative 'instance_container'

class EDURange::Docker::Instance
  include SemanticLogger::Loggable
  extend Forwardable

  def initialize(subnet, instance_config)
    @subnet = subnet
    @instance_config = instance_config
    @container = EDURange::Docker::InstanceContainer.find(instance_config)
    @image = EDURange::Docker::InstanceImage.find(instance_config)
  end

  delegate [:name, :os, :ip_address, :ip_address_dynamic, :users, :administrators, :recipes, :scripts, :packages, :internet_accessible?, :roles, :scripts] => :@instance_config
  alias_method(:players, :users)

  # TODO, the following three definitions are identical to core/instance definition.
  # this class should extend that class
  def subnet
    @subnet
  end

  def scenario
    subnet.scenario
  end

  def cloud
    subnet.cloud
  end

  def started?
    container = EDURange::Docker::InstanceContainer.find(@instance_config)
    not container.nil? and container.info["State"] == 'running'
  end

  def start
    logger.trace 'building_image', instance: name
    @image = EDURange::Docker::InstanceImage.build(@instance_config) unless @image
    logger.trace 'pushing_image', instance: name
    @image.push

    @container = EDURange::Docker::InstanceContainer.create(@image, @instance_config) unless @container
    logger.trace 'starting container', instance: name
    @container.start
  end

  def stop
    if @container then
      logger.trace'stopping container'
      @container.stop
      logger.trace'removing container'
      @container.remove
    end
    if @image then
      logger.trace'removing image'
      @image.remove
    end
  end

  def public_ip_address
    IPAddress.parse '127.0.0.1' # TODO: just a hack to get started. Running docker on localhost.
  end

  # kind of a hack, is ssh_port provider specific?
  def host_ssh_port
    if @container
      @container.json['NetworkSettings']['Ports']['22/tcp'].first['HostPort'].to_i
    end
  end

  def create_build_directory(path)
    EDURange::Docker::InstanceImage.create_build_directory(path, self)
  end

  # TODO, should weird internals be exposed? for debugging, they seem useful.
#  def with_docker_build_directory(&block)
#    EDURange::Docker::InstanceImage.with_docker_build_directory(self, &block)
#  end



end

