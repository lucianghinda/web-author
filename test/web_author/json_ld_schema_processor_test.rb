# frozen_string_literal: true

require 'test_helper'

class WebAuthor::JsonLdSchemaProcessorTest < Minitest::Test
  def test_schemas_returns_empty_array_when_no_schema_found
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Page</title>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
      </html>
    HTML

    document = Nokogiri::HTML(html)
    processor = WebAuthor::JsonLdSchemaProcessor.new(document:)

    assert_empty processor.schemas
  end

  def test_schemas_extracts_single_schema
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Page</title>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Article",
            "name": "Test Article",
            "author": "John Doe"
          }
        </script>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
      </html>
    HTML

    document = Nokogiri::HTML(html)
    processor = WebAuthor::JsonLdSchemaProcessor.new(document:)

    schemas = processor.schemas

    assert_equal 1, schemas.size
    assert_instance_of WebAuthor::LdSchema, schemas.first
    assert_equal 'https://schema.org', schemas.first.context
    assert_equal 'Article', schemas.first.type
    assert_equal 'Test Article', schemas.first.name
    assert_equal 'John Doe', schemas.first.author
  end

  def test_schemas_extracts_multiple_schemas # rubocop:disable Minitest/MultipleAssertions
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Page</title>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Article",
            "name": "Test Article 1",
            "author": "John Doe"
          }
        </script>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "BlogPosting",
            "name": "Test Article 2",
            "author": {
              "@type": "Person",
              "name": "Jane Smith"
            }
          }
        </script>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
      </html>
    HTML

    document = Nokogiri::HTML(html)
    processor = WebAuthor::JsonLdSchemaProcessor.new(document:)

    schemas = processor.schemas

    assert_equal 2, schemas.size

    assert_instance_of WebAuthor::LdSchema, schemas[0]
    assert_equal 'https://schema.org', schemas[0].context
    assert_equal 'Article', schemas[0].type
    assert_equal 'Test Article 1', schemas[0].name
    assert_equal 'John Doe', schemas[0].author

    assert_instance_of WebAuthor::LdSchema, schemas[1]
    assert_equal 'https://schema.org', schemas[1].context
    assert_equal 'BlogPosting', schemas[1].type
    assert_equal 'Test Article 2', schemas[1].name
    assert_equal({ '@type' => 'Person', 'name' => 'Jane Smith' }, schemas[1].author)
  end

  def test_schemas_skips_invalid_json
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Page</title>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Article",
            "name": "Test Article",
            "author": "John Doe"
          }
        </script>
        <script type="application/ld+json">
          { This is invalid JSON }
        </script>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "BlogPosting",
            "name": "Test Article 2",
            "author": "Jane Smith"
          }
        </script>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
      </html>
    HTML

    document = Nokogiri::HTML(html)
    processor = WebAuthor::JsonLdSchemaProcessor.new(document:)

    schemas = processor.schemas

    assert_equal 2, schemas.size
    assert_equal 'Article', schemas[0].type
    assert_equal 'BlogPosting', schemas[1].type
  end

  def test_schemas_skips_empty_script_tags
    html = <<~HTML
      <!DOCTYPE html>
      <html>
      <head>
        <title>Test Page</title>
        <script type="application/ld+json">
          {
            "@context": "https://schema.org",
            "@type": "Article",
            "name": "Test Article",
            "author": "John Doe"
          }
        </script>
        <script type="application/ld+json"></script>
        <script type="application/ld+json"></script>
      </head>
      <body>
        <h1>Hello, World!</h1>
      </body>
      </html>
    HTML

    document = Nokogiri::HTML(html)
    processor = WebAuthor::JsonLdSchemaProcessor.new(document:)

    schemas = processor.schemas

    assert_equal 1, schemas.size
    assert_equal 'Article', schemas[0].type
  end
end
