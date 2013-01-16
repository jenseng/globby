# globby

globby is a [.gitignore](http://www.kernel.org/pub/software/scm/git/docs/gitignore.html)-compatible file globber for ruby

## Installation

Put `gem 'globby'` in your Gemfile.

## Usage

    Globby.new(rules).matches

### An example:

     > rules = File.read('.gitignore').split(/\n/)
     > pp Globby.new(rules).matches
    ["Gemfile.lock",
     "doc/Foreigner.html",
     "doc/Foreigner/Adapter.html",
     "doc/Gemfile.html",
     "doc/Immigrant.html",
     ...
     "immigrant-0.1.3.gem",
     "immigrant-0.1.4.gem"]
    => nil

## Why on earth would I ever use this?

* You're curious what is getting `.gitignore`'d and/or you want to do something
  with those files.
* You're writing a library/tool that will have its own list of ignored/tracked
  files. My use case is for an I18n library that extracts strings from ruby
  files... I need to provide users a nice configurable way to whitelist given
  files/directories/patterns.

## License

Copyright (c) 2012 Jon Jensen, released under the MIT license
