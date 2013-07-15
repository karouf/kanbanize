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

  gem.add_runtime_dependency 'httparty', '~> 0.11.0'

  gem.add_development_dependency 'rake', '~> 10.0.3'
  gem.add_development_dependency 'minitest' ,'~> 4.7.5'
  gem.add_development_dependency 'minitest-reporters', '~> 0.14.20'
  gem.add_development_dependency 'webmock', '>= 1.8.0', '< 1.12'
  gem.add_development_dependency 'vcr', '~> 2.5.0'
  gem.add_development_dependency 'yard', '~> 0.8.6.2'
  gem.add_development_dependency 'redcarpet', '~> 3.0.0'
end
