# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ffi-markdown/version"

Gem::Specification.new do |s|
  s.name        = "ffi-markdown"
  s.version     = Markdown::VERSION
  s.authors     = ["Alex MacCaw"]
  s.email       = ["maccman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby Markdown lib}
  s.description = %q{Ruby Markdown lib}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency(%q<ffi>, [">= 1.0.9"])
end
