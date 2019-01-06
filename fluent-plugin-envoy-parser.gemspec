# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-envoy-parser"
  spec.version       = "0.0.6"
  spec.description   = 'Fluentd parser plugin to parse standard Envoy Proxy access logs'
  spec.authors       = ["salrashid123"]
  spec.email         = ["salrashid123@gmail.com"]
  spec.summary       = %q{Fluentd parser plugin to parse envoy HTTP/TCP access logs for Fluentd and Google Cloud Logging}
  spec.homepage      = "https://github.com/salrashid123/fluent-plugin-envoy-parser"
  spec.license       = "Apache License, Version 2.0"

  spec.files       = ["lib/fluent/plugin/parser_envoy.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", '~> 1.15.0'
  spec.add_development_dependency "rake", '~> 11.1.2'
  spec.add_development_dependency "test-unit", '~> 3.0'  
  spec.add_runtime_dependency "fluentd", ['>= 0.14.0']
end
