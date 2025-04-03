# frozen_string_literal: true

require_relative 'lib/web_author/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = 'web_author'
  spec.version = WebAuthor::VERSION
  spec.authors = ['Lucian Ghinda']
  spec.email = ['1407869+lucianghinda@users.noreply.github.com']

  spec.summary = 'Detect Author for a web page'
  spec.description = 'This gem tried to detect author for a webpage based on various strategies'
  spec.homepage = 'https://github.com/lucianghinda/web_author'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['allowed_push_host'] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/lucianghinda/web_author'
  spec.metadata['changelog_uri'] = 'https://github.com/lucianghinda/web_author/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w(git ls-files -z), chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w(bin/ test/ spec/ features/ .git .github appveyor Gemfile))
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'nokogiri', '~> 1.15'
  spec.add_dependency 'sorbet-runtime', '~> 0.5'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
