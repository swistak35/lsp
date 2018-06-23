# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'lsp'
  spec.version       = '0.0.1'
  spec.licenses      = ['MIT']
  spec.authors       = ['Rafał Łasocha']
  spec.email         = 'lsp@swistak35.com'

  spec.summary       = "Language Server Protocol implementation"
  spec.description   = "A simple hello world gem"
  spec.homepage      = 'https://github.com/swistak35/language_server_protocol'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
  spec.add_development_dependency 'byebug'
end
