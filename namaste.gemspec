# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "namaste/version"

Gem::Specification.new do |s|
  s.name        = "namaste"
  s.version     = Namaste::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Chris Beer"]
  s.email       = %q{chris@cbeer.info}
  s.homepage    = "http://github.com/microservices/namaste"
  s.summary     = %q{A ruby client implementation of the Namaste specification for directory description with filename-based tags.}
  s.description = %q{TODO: Write a gem description}

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.default_executable = %q{namaste}
  s.require_paths      = ["lib"]

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  
  s.licenses = ["Apache2"]
  
  s.rubygems_version = %q{1.3.7}

  s.add_dependency("i18n")
  s.add_development_dependency("rcov")
  s.add_development_dependency("bundler", "~>1.0.0")
  s.add_development_dependency("rspec", ">2.0.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("RedCloth")

end

