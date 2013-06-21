# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kanbanize/version'

Gem::Specification.new do |gem|
  gem.name          = "kanbanize"
  gem.version       = Kanbanize::VERSION
  gem.authors       = ["Renaud Martinet"]
  gem.email         = ["karouf@gmail.com"]
  gem.description   = %q{Ruby wrapper around the Kanbanize API}
  gem.summary       = %q{See http://kanbanize.com/ctrl_integration for API information}
  gem.homepage      = "https://github.com/karouf/kanbanize"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
