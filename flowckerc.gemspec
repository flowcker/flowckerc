# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flowckerc/version'

Gem::Specification.new do |spec|
  spec.name          = "flowckerc"
  spec.version       = Flowckerc::VERSION
  spec.authors       = ["Leo Lara"]
  spec.email         = ["leo@leolara.me"]

  spec.summary       = %q{flowckerc is Flowcker formula compiler}
  spec.description   = %q{Flowcker is a distributed processing platform, based on Flow based programming and linux containers (Docker).}
  spec.homepage      = "http://www.flowcker.io"
  spec.license       = "AGPLv3"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "hike", "~> 2.1.3"
  spec.add_runtime_dependency "json", "~> 1.8.1"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
