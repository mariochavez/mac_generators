$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mac_generators/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "mac_generators"
  s.version = MacGenerators::VERSION
  s.authors = "Mario A Chavez"
  s.email = "mario.chavez@gmail.com"
  s.homepage = "https://mariochavez.io"
  s.summary = "Custom generators."
  s.description = "Includes 3 generators, the first two are to create a Rails authentication. The last one is to add bootstrap to a rails application"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 6.0.0"

  s.add_development_dependency "standardrb"
end
