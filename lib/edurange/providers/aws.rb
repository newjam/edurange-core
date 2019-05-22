require 'aws-sdk-ec2'
require 'aws-sdk-s3'
require 'aws-sdk-iam'

require_relative 'aws/scenario'

module EDURange
  module AWS
    def self.wrap(config)
      AWS.assert_environment_variables_present
      ec2 = Aws::EC2::Resource.new
      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      Scenario.new(ec2, s3, config)
    end

    def AWS.assert_environment_variables_present
      required_variables = [
        'AWS_ACCESS_KEY_ID',
        'AWS_SECRET_ACCESS_KEY',
        'AWS_REGION'
      ]

      missing_variables = required_variables.select{|name| not ENV.include?(name)}

      if not missing_variables.empty? then
        raise 'Missing environment variable(s): ' + missing_variables.join(', ')
      end
    end

  end
end

