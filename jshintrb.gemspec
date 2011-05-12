Gem::Specification.new do |s|
  s.name = "jshintrb"
  s.version = "1.0.1"
  s.platform = Gem::Platform::RUBY
  s.author = "Rebecca Murphey"
  s.email = "rmurphey@gmail.com"
  s.homepage = "http://www.github.com/rmurphey/jshintrb"
  s.summary = "Run JSHint from Ruby. Based on jslintrb_v8 from ngauthier."
  s.rubygems_version = '>= 1.3.6'

  s.files = Dir['lib/**/*'] + ['README.rdoc']

  s.add_dependency('therubyracer', '0.8.0')
end
