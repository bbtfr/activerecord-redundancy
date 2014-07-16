$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "redundancy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord-redundancy"
  s.version     = Redundancy::VERSION
  s.authors     = ["Theo"]
  s.email       = ["bbtfrr@gmail.com"]
  s.summary     = "Wrap your objects with a helper to easily list them"
  s.description = "Wrap your objects with a helper to easily list them"
  s.homepage    = "https://bbtfr.github.io/activerecord-redundancy"
  s.license     = "MIT"

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2", "< 5"

  s.add_development_dependency "sqlite3"
end
