# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'swedish_holidays'
  gem.version     = '1.0.0'
  gem.summary     = "Swedish holidays"
  gem.description = "Check if a date is a swedish holiday"
  gem.authors     = ["Sammy Henningsson"] 
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.homepage    = "https://github.com/sammyhenningsson/swedish_holidays"
  gem.license     = "MIT"

  gem.files         = Dir['lib/**/*rb']
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.3'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'nokogiri', '~> 1.8'
end
