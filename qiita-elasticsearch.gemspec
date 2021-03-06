lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qiita/elasticsearch/version"

Gem::Specification.new do |spec|
  spec.name          = "qiita-elasticsearch"
  spec.version       = Qiita::Elasticsearch::VERSION
  spec.authors       = ["Ryo Nakamura"]
  spec.email         = ["r7kamura@gmail.com"]
  spec.summary       = "Elasticsearch client helper for Qiita."
  spec.homepage      = "https://github.com/increments/qiita-elasticsearch"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler", ">= 1.7"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rubocop", "0.29.1"
end
