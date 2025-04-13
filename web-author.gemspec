# frozen_string_literal: true

require_relative 'lib/web_author/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name = 'web-author'
  spec.version = WebAuthor::VERSION
  spec.authors = ['Lucian Ghinda']
  spec.email = ['lucian@shortruby.com']

  spec.summary = 'Detect Author for a web page'
  spec.description = 'This gem tries to detect author for a webpage based on various strategies.' \
                     'Currently supports JSON-LD and meta author tag'
  spec.homepage = 'https://github.com/lucianghinda/web-author'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/lucianghinda/web-author'
  spec.metadata['changelog_uri'] = 'https://github.com/lucianghinda/web-author/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w(git ls-files -z), chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w(bin/ test/ .git .gitignore .github .rubocop.yml Gemfile CLAUDE.md))
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.15'
  spec.add_dependency 'sorbet-runtime', '~> 0.5'
  spec.add_dependency 'zeitwerk', '~> 2.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
