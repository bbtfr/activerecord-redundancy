$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "redundancy/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord-redundancy"
  s.version     = Redundancy::VERSION
  s.authors     = ["Theo"]
  s.email       = ["bbtfrr@gmail.com"]
  s.summary     = "Redundancy for better performance, non painful"
  s.description = "Quickly make a cache column in ActiveRecord, non painful"
  s.homepage    = "https://github.com/bbtfr/activerecord-redundancy"
  s.license     = "MIT"

  s.files       = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files  = Dir["test/**/*"]

  s.add_dependency "activerecord", ">= 3.2", "< 5"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "pry-rescue"
  s.add_development_dependency "pry-stack_explorer"
  s.add_development_dependency "rails"
end
