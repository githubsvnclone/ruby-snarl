require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = "ruby-snarl"
  s.version = "0.0.5"
  s.author = "Patrick Hurley"
  s.email = "phurley@gmail.com"
  s.homepage = "http://ruby-snarl.rubyforge.org/"
  s.platform = Gem::Platform::RUBY
  s.summary = "Snarl (http://www.fullphat.net/snarl.html) is a simple notification system, similar to Growl under OSX. This is a simple pure Ruby wrapper to the native API (using DL)."
  s.files = Dir["**/*"]
  s.autorequire = "ruby-snarl"
end

if  __FILE__ == $PROGRAM_NAME
  Gem::manage_gems
  Gem::Builder.new(spec).build
end