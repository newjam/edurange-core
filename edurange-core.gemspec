
Gem::Specification.new do |s|
  s.name        = 'edurange-core'
  s.version     = '0.0.0'
  s.date        = '2018-07-19'
  s.summary     = 'Backend for edurange cybersecurity playground'
  s.description = ''
  s.authors     = ['James Newman']
  s.email       = 'jameshildrethnewman@gmail.com'
  s.files       = `git ls-files lib README.md`.split($\)
  s.executables << 'edurange'
  s.homepage    = ''
  s.license     = 'MIT'

  # Runtime Dependcies
  s.add_runtime_dependency 'activesupport', '5.2.0'
  s.add_runtime_dependency 'ipaddress', '0.8.3'
  s.add_runtime_dependency 'mustache', '1.0.5'
  s.add_runtime_dependency 'erubis', '2.7.0'
  s.add_runtime_dependency 'unix-crypt', '1.3.0'
  s.add_runtime_dependency 'semantic_logger', '4.3.0'

  # AWS provider specific files
  s.add_runtime_dependency 'aws-sdk-ec2', '1.51.0'
  s.add_runtime_dependency 'aws-sdk-s3', '1.21.0'
  s.add_runtime_dependency 'aws-sdk-iam', '1.21.0'

  # Docker provider specific files
  s.add_runtime_dependency 'docker-api', '1.34.2'

  # Development Dependencies
  s.add_development_dependency 'net-ssh', '5.0.2'
  s.add_development_dependency 'minitest-reporters'
end

