# frozen_string_literal: true

require_relative 'lib/tame_impala/version'

Gem::Specification.new do |spec|
  spec.name          = 'tame_impala'
  spec.version       = TameImpala::VERSION
  spec.authors       = ['ann-ann']
  spec.email         = ['saddy666@gmail.com']

  spec.summary       = 'Web crawler for articles'
  spec.homepage      = 'https://github.com/ann-ann/tame_impala'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ann-ann/tame_impala'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('concurrent-ruby')
  spec.add_dependency('nokogiri')
  spec.add_dependency('rake')
  spec.add_dependency('rspec')
  spec.add_dependency('ruby-readability')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('vcr')
  spec.add_development_dependency('webmock')
end
