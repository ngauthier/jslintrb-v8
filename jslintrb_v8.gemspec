Gem::Specification.new do |s|
  s.name = "jslintrb_v8"
  s.version = "1.0.2"
  s.platform = Gem::Platform::RUBY
  s.author = "Nick Gauthier"
  s.email = "ngauthier@gmail.com"
  s.homepage = "http://www.github.com/ngauthier/jslintrb_v8"
  s.summary = "Run JSLint from Ruby"
  s.rubygems_version = '>= 1.3.6'

  s.files = Dir['lib/**/*'] + ['README.rdoc']
  
  s.add_dependency('therubyracer', '0.8.1')
end
