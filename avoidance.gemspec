$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'avoidance/version'

Gem::Specification.new do |s|
  s.name     = "avoidance"
  s.version  = ::Avoidance::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://camerondutro.com"

  s.description = s.summary = "Manipulate ActiveRecord models and their associations naturally without persisting them to the database."
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'rails', '>= 3.1'

  s.require_path = 'lib'
  s.files = Dir["{lib}/**/*", "Gemfile", "History.txt", "LICENSE", "README.md", "Rakefile", "avoidance.gemspec"]
end
