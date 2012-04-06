# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/wordstats/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sergey Gopkalo"]
  gem.email         = ["Sergey.Gopkalo@gmail.com"]
  gem.description   = %q{Steal wordstats from yandex}
  gem.summary       = %q{Retrieve wordstats from wordstat.yandex.ru }
  gem.homepage      = ""

  gem.add_development_dependency "mechanize"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "activerecord"
  gem.add_development_dependency "sqlite3"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "wordstats"
  gem.require_paths = ["lib"]
  gem.version       = Wordstats::VERSION
end
