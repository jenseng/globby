# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'globby'
  s.version = '0.0.2'
  s.summary = '.gitignore-compatible file globber'
  s.description = 'find files using .gitignore-style globs'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Jon Jensen'
  s.email             = 'jenseng@gmail.com'
  s.homepage          = 'http://github.com/jenseng/globby'

  s.files = %w(LICENSE.txt Rakefile README.md) + Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
end
