require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = "ruby-snarl"
  s.version = "0.0.1"
  s.author = "phurley"
  # s.email = ""
  # s.homepage = ""
  s.platform = Gem::Platform::RUBY
  s.summary = "Snarl (http://www.fullphat.net/snarl.html) is a simple notification system, similar to Growl under OSX. This is a simple pure Ruby wrapper to the native API (using DL)."
  s.files = Dir["**/*"]
  #~ s.require_path = "."
  s.autorequire = "ruby-snarl"
  #~ s.extensions = ["ext/extconf.rb"]
end

if  __FILE__ == $PROGRAMNAME
  Gem::manage_gems
  Gem::Builder.new(spec).build
end