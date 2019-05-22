
require 'edurange/core/scenario'
require 'forwardable'
require_relative 'cloud'

module EDURange
  module AWS
    class Scenario
      extend Forwardable

      def initialize(ec2, s3, scenario)
        @ec2 = ec2
        @s3 = s3
        @config = scenario
      end

      # a globally unique identifier for this EduRange instance.
      def identifier
        # todo: needs additional identifier to differentiate between instances of scenarios.
        "edurange:#{name}"
      end

      delegate [:name, :description, :roles, :groups] => :@config

      def clouds
        @clouds ||= @config.clouds.map{ |cloud| EDURange::AWS::Cloud.new(@ec2, @s3, cloud) }
      end

      def started?
        clouds.all? { |cloud| cloud.started? }
      end

      def start
        clouds.each{ |cloud| cloud.start }
      end

      def stop
        clouds.each{ |cloud| cloud.stop }
      end

    end
  end
end

