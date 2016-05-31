# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'RBotKit/version'

Gem::Specification.new do |spec|
  spec.name          = "RBotKit"
  spec.version       = RBotKit::VERSION
  spec.authors       = ["alexej"]
  spec.email         = ["a-nenastev@mail.ru"]

  spec.summary       = "Bot Kit for telegramm"
  spec.description   = "Bot Kit for telegramm"
  spec.homepage      = "https://github.com/alexejn/RBotKit.git"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

 
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "2.99.0"   
  spec.add_dependency 'rest-client', '~> 1.8' 
  spec.add_dependency 'i18n', '~> 0'
end
