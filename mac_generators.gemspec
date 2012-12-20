$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mac_generators/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mac_generators"
  s.version     = MacGenerators::VERSION
  s.authors     = 'Mario A Chavez'
  s.email       = 'mario.chavez@gmail.com'
  s.homepage    = "http://mario-chavez.decisionesinteligentes.com"
  s.summary     = "Custom generators."
  s.description = "Includes 2 generators, the first one is to create a Rails authentication. The second on is to add bootstrap to a rails application"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0.beta"

  s.add_development_dependency "sqlite3"
end
