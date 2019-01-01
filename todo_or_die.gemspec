lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "todo_or_die"

Gem::Specification.new do |spec|
  spec.name          = "todo_or_die"
  spec.version       = TodoOrDie::VERSION
  spec.authors       = ["Justin Searls"]
  spec.email         = ["searls@gmail.com"]

  spec.summary       = "Write TO​DOs in code that ensure you actually do them"
  spec.homepage      = "https://github.com/testdouble/todo_or_die"

  spec.files         = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "standard"
  spec.add_development_dependency "timecop"
end
