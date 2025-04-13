# WebAuthor

WebAuthor is a Ruby gem that extracts author information from web pages using multiple strategies. It can detect authors from both meta tags and JSON-LD schema, providing a reliable way to identify content creators.

## Features

- Extract author information from HTML meta tags
- Extract author information from JSON-LD schema (schema.org)
- Support for multiple authors in a single page
- Fallback strategy - tries different methods until an author is found
- Clean, type-safe code with Sorbet

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'web_author'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install web_author
```

## Usage

### Basic Usage

```ruby
require 'web_author'

# Create a new Page object with a URL
page = WebAuthor::Page.new(url: 'https://example.com/article')

# Get the author of the page
author = page.author
# => "John Doe"
```

WebAuthor will first try to find author information in JSON-LD schema data, then fall back to meta tags if needed.

### Handling Multiple Authors

If a page has multiple authors in the JSON-LD schema, WebAuthor returns them as a comma-separated string:

```ruby
page = WebAuthor::Page.new(url: 'https://example.com/collaboration-article')
authors = page.author
# => "Jane Smith, Bob Johnson"
```

### Error Handling

WebAuthor raises `WebAuthor::Error` when it encounters problems fetching the page:

```ruby
begin
  page = WebAuthor::Page.new(url: 'https://example.com/article')
  author = page.author
rescue WebAuthor::Error => e
  puts "Failed to get author: #{e.message}"
end
```

## How It Works

WebAuthor uses a strategy to extract author information:

1. First, it tries to find author information in JSON-LD schema (often found in `<script type="application/ld+json">` tags)
2. If no author is found in JSON-LD, it looks for a meta tag with the name "author" (`<meta name="author" content="Author Name">`)
3. If no author is found using any strategy, it returns `nil`

## Supported Author Formats

### Meta Tags

```html
<meta name="author" content="Author Name" />
```

### JSON-LD Schema

Single author:

```html
<script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "author": {
      "@type": "Person",
      "name": "Author Name"
    }
  }
</script>
```

Multiple authors:

```html
<script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Article",
    "author": [
      {
        "@type": "Person",
        "name": "First Author"
      },
      {
        "@type": "Person",
        "name": "Second Author"
      }
    ]
  }
</script>
```

## Requirements

- Ruby 3.4 or higher
- Nokogiri
- Sorbet Runtime
- Zeitwerk

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Development Workflow

#### Type Checking with Sorbet

This project uses [Sorbet](https://sorbet.org/) for static type checking. To run the type checker:

```bash
$ bin/type-check
```

or directly:

```bash
$ bundle exec srb tc
```

#### Running Tests

Run all tests using:

```bash
$ bundle exec rake test
```

Run a specific test file:

```bash
$ bundle exec ruby -Ilib:test test/web_author/page_test.rb
```

#### Code Style and Linting

This project follows Ruby style guidelines enforced by RuboCop. Run the linter with:

```bash
$ bundle exec rubocop
```

Auto-fix issues when possible:

```bash
$ bundle exec rubocop -A
```

#### Running All Checks

The default Rake task runs both tests and RuboCop:

```bash
$ bundle exec rake
```

### Working with Sorbet

WebAuthor uses Sorbet for static type checking. When adding new code:

1. Add comment on top of the file: `# typed: strict`
2. Add type signatures to methods using `sig` blocks
3. Run `bin/type-check` to verify type safety

Example of typed code:

```ruby
extend T::Sig

sig { params(url: String).void }
def initialize(url:)
  @url = T.let(url, String)
  @content = T.let(nil, T.nilable(String))
end

sig { returns(T.nilable(String)) }
def author
  # method implementation
end
```

### Adding a new strategy

You should create a new class that inherits from `WebAuthor::Strategy` and implement the `author` method.
You will notice that you will get the `document` from the initializer as every strategy receives it. This is a `Nokogiri::XML::Document` object.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Bug reports and pull requests are welcome on GitHub at https://github.com/lucianghinda/web_author.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
