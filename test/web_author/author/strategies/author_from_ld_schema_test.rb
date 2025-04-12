# frozen_string_literal: true

require 'test_helper'

class WebAuthor::Author::Strategies::AuthorFromLdSchemaTest < Minitest::Test
  def test_author_returns_name_from_json_ld_schema
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": {
                "@type": "Person",
                "name": "Jane Doe",
                "url": "https://example.com/janedoe"
              }
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_equal 'Jane Doe', author_from_ld_schema.author
  end

  def test_author_returns_name_when_author_is_string
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": "John Smith"
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_equal 'John Smith', author_from_ld_schema.author
  end

  def test_author_returns_comma_separated_names_for_multiple_authors
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": [
                {
                  "@type": "Person",
                  "name": "Alice Cooper",
                  "url": "https://example.com/alice"
                },
                {
                  "@type": "Person",
                  "name": "Bob Johnson",
                  "url": "https://example.com/bob"
                }
              ]
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_equal 'Alice Cooper, Bob Johnson', author_from_ld_schema.author
  end

  def test_author_returns_comma_separated_names_from_multiple_schemas
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": {
                "@type": "Person",
                "name": "Jane Doe",
                "url": "https://example.com/janedoe"
              }
            }
          </script>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "BlogPosting",
              "headline": "Another Test Article",
              "author": {
                "@type": "Person",
                "name": "John Smith",
                "url": "https://example.com/johnsmith"
              }
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_equal 'Jane Doe, John Smith', author_from_ld_schema.author
  end

  def test_author_returns_unique_names_when_duplicate_authors_exist
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": {
                "@type": "Person",
                "name": "Jane Doe",
                "url": "https://example.com/janedoe"
              }
            }
          </script>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "BlogPosting",
              "headline": "Another Test Article",
              "author": {
                "@type": "Person",
                "name": "Jane Doe",
                "url": "https://example.com/janedoe"
              }
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_equal 'Jane Doe', author_from_ld_schema.author
  end

  def test_author_returns_nil_when_no_json_ld_schema_exists
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Test Page</title>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_nil author_from_ld_schema.author
  end

  def test_author_returns_nil_when_json_ld_schema_has_no_author
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article"
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_nil author_from_ld_schema.author
  end

  def test_author_returns_nil_when_all_authors_have_no_name
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "headline": "Test Article",
              "author": [
                {
                  "@type": "Person",
                  "url": "https://example.com/unknown1"
                },
                {
                  "@type": "Person",
                  "url": "https://example.com/unknown2"
                }
              ]
            }
          </script>
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)
    author_from_ld_schema = WebAuthor::Author::Strategies::AuthorFromLdSchema.new(document)

    assert_nil author_from_ld_schema.author
  end
end
