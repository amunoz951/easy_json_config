# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'easy_json_config'
  spec.version       = '0.4.0'
  spec.authors       = ['Alex Munoz']
  spec.email         = ['amunoz951@gmail.com']
  spec.license       = 'Apache-2.0'
  spec.summary       = 'Ruby library for ease of using a basic json config file with the ability to specify default values.'
  spec.homepage      = 'https://github.com/amunoz951/easy_json_config'

  spec.required_ruby_version = '>= 2.3'

  spec.files         = Dir['LICENSE', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'json', '~> 2'
  spec.add_dependency 'hashly', '~> 0'
end
