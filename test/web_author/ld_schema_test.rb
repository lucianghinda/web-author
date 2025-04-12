# frozen_string_literal: true

require 'test_helper'
require 'json'

class WebAuthor::LdSchemaTest < Minitest::Test
  def test_initializes_with_context_and_type
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article'
    )

    assert_equal 'https://schema.org', schema.context
    assert_equal 'Article', schema.type
  end

  def test_initializes_with_all_properties # rubocop:disable Minitest/MultipleAssertions -- disabled because it makes sense to check all attributes in a single test. While this has multiple lines of assertion this is one single verification.
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      id: 'https://example.com/article1',
      name: 'Test Article',
      description: 'Article description',
      url: 'https://example.com/article1',
      image: 'https://example.com/article1.jpg',
      author: 'John Doe'
    )

    assert_equal 'https://schema.org', schema.context
    assert_equal 'Article', schema.type
    assert_equal 'https://example.com/article1', schema.id
    assert_equal 'Test Article', schema.name
    assert_equal 'Article description', schema.description
    assert_equal 'https://example.com/article1', schema.url
    assert_equal 'https://example.com/article1.jpg', schema.image
    assert_equal 'John Doe', schema.author
  end

  def test_initializes_with_context_as_hash
    context_hash = { '@vocab' => 'https://schema.org/' }
    schema = WebAuthor::LdSchema.new(
      context: context_hash,
      type: 'Article'
    )

    assert_equal context_hash, schema.context
  end

  def test_initializes_with_type_as_array
    type_array = ['Article', 'BlogPosting']
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: type_array
    )

    assert_equal type_array, schema.type
  end

  def test_initializes_with_author_as_hash
    author_hash = { '@type' => 'Person', 'name' => 'John Doe' }
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: author_hash
    )

    assert_equal author_hash, schema.author
  end

  def test_initializes_with_author_as_array
    author_array = [
      { '@type' => 'Person', 'name' => 'John Doe' },
      { '@type' => 'Person', 'name' => 'Jane Smith' }
    ]
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: author_array
    )

    assert_equal author_array, schema.author
  end

  def test_parsed_author_with_string
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: 'John Doe'
    )

    parsed = schema.parsed_author

    assert_instance_of WebAuthor::LdAuthor, parsed
    assert_equal 'John Doe', parsed.name
  end

  def test_parsed_author_with_hash
    author_hash = { '@type' => 'Person', 'name' => 'John Doe', 'url' => 'https://example.com/john' }
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: author_hash
    )

    parsed = schema.parsed_author

    assert_instance_of WebAuthor::LdAuthor, parsed
    assert_equal 'Person', parsed.type
    assert_equal 'John Doe', parsed.name
    assert_equal 'https://example.com/john', parsed.url
  end

  def test_parsed_author_with_array # rubocop:disable Minitest/MultipleAssertions
    author_array = [
      { '@type' => 'Person', 'name' => 'John Doe', 'url' => 'https://example.com/john' },
      { '@type' => 'Person', 'name' => 'Jane Smith', 'url' => 'https://example.com/jane' }
    ]
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: author_array
    )

    parsed = schema.parsed_author

    assert_instance_of Array, parsed
    assert_equal 2, parsed.size
    assert_instance_of WebAuthor::LdAuthor, parsed.first
    assert_equal 'Person', parsed.first.type
    assert_equal 'John Doe', parsed.first.name
    assert_equal 'https://example.com/john', parsed.first.url
    assert_instance_of WebAuthor::LdAuthor, parsed.last
    assert_equal 'Person', parsed.last.type
    assert_equal 'Jane Smith', parsed.last.name
    assert_equal 'https://example.com/jane', parsed.last.url
  end

  def test_author_additional_properties
    author_hash = {
      '@type' => 'Person',
      'name' => 'John Doe',
      'url' => 'https://example.com/john',
      'jobTitle' => 'Writer',
      'affiliation' => 'Example Inc.'
    }
    schema = WebAuthor::LdSchema.new(
      context: 'https://schema.org',
      type: 'Article',
      author: author_hash
    )

    parsed = schema.parsed_author

    assert_instance_of WebAuthor::LdAuthor, parsed
    assert_equal 'Person', parsed.type
    assert_equal 'John Doe', parsed.name
    assert_equal 'https://example.com/john', parsed.url
    assert_equal({ 'jobTitle' => 'Writer', 'affiliation' => 'Example Inc.' }, parsed.additional_properties)
  end

  def test_captures_additional_properties
    hash = {
      '@context' => 'https://schema.org',
      '@type' => 'Article',
      'datePublished' => '2023-01-01',
      'publisher' => { '@type' => 'Organization', 'name' => 'Test Publisher' }
    }

    schema = WebAuthor::LdSchema.from_hash(hash)

    expected_additional = {
      'datePublished' => '2023-01-01'
    }

    assert_equal expected_additional, schema.additional_properties
    assert_equal({ '@type' => 'Organization', 'name' => 'Test Publisher' }, schema.publisher)
  end

  def test_from_script_tag_parses_json_correctly
    script_tag = <<~JSON
      {
        "@context": "https://schema.org",
        "@type": "Article",
        "name": "Test Article",
        "author": "John Doe"
      }
    JSON

    schema = WebAuthor::LdSchema.from_script_tag(script_tag)

    assert_equal 'https://schema.org', schema.context
    assert_equal 'Article', schema.type
    assert_equal 'Test Article', schema.name
    assert_equal 'John Doe', schema.author
  end

  def test_from_script_tag_with_complex_json # rubocop:disable Minitest/MultipleAssertions  --  disabled because it makes sense to check all attributes in a single test. While this has multiple lines of assertion this is one single verification.
    script_tag = <<~JSON
      {
        "@context": "https://schema.org",
        "@type": ["Article", "BlogPosting"],
        "@id": "https://example.com/article1",
        "name": "Test Article",
        "description": "Article description",
        "url": "https://example.com/article1",
        "image": "https://example.com/article1.jpg",
        "author": {
          "@type": "Person",
          "name": "John Doe"
        },
        "datePublished": "2023-01-01",
        "publisher": {
          "@type": "Organization",
          "name": "Test Publisher"
        }
      }
    JSON

    schema = WebAuthor::LdSchema.from_script_tag(script_tag)

    assert_equal 'https://schema.org', schema.context
    assert_equal ['Article', 'BlogPosting'], schema.type
    assert_equal 'https://example.com/article1', schema.id
    assert_equal 'Test Article', schema.name
    assert_equal 'Article description', schema.description
    assert_equal 'https://example.com/article1', schema.url
    assert_equal 'https://example.com/article1.jpg', schema.image
    assert_equal({ '@type' => 'Person', 'name' => 'John Doe' }, schema.author)
    assert_equal({ '@type' => 'Organization', 'name' => 'Test Publisher' }, schema.publisher)

    expected_additional = {
      'datePublished' => '2023-01-01'
    }

    assert_equal expected_additional, schema.additional_properties
  end

  def test_real_example_1
    script_tag = <<~JSON
      {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "headline": "This is the title of this blog post",
        "author": [
          {
            "@type": "Person",
            "name": "Rob Snow",
            "url": "http://example.com/rob-snow"
          }
        ],
        "datePublished": "2025-03-31T00:00:00Z",
        "dateModified": "2025-03-25T07:24:23Z",
        "description": "This is the description of this blog post."
      }
    JSON

    schema = WebAuthor::LdSchema.from_script_tag(script_tag)

    assert_equal 'https://schema.org', schema.context
    assert_equal 'BlogPosting', schema.type
    assert_equal 'This is the description of this blog post.', schema.description
    assert_equal 'This is the title of this blog post', schema.headline
    assert_equal({ '@type' => 'Person', 'name' => 'Rob Snow', 'url' => 'http://example.com/rob-snow' }, schema.author.first)

    expected_additional = {
      'datePublished' => '2025-03-31T00:00:00Z',
      'dateModified' => '2025-03-25T07:24:23Z'
    }

    assert_equal expected_additional, schema.additional_properties
  end

  def test_blog_with_blog_posts # rubocop:disable Minitest/MultipleAssertions -- disabled because it makes sense to check all attributes in a single test. While this has multiple lines of assertion this is one single verification.
    script_tag = <<~JSON
      {
        "@context": "https://schema.org",
        "@type": "Blog",
        "name": "Short Notes",
        "url": "https://notes.ghinda.com",
        "description": "Short posts mostly about Ruby and Ruby on Rails.",
        "image": "https://example.com/image.png",
        "publisher": {
          "@type": "Person",
          "name": "Short Notes"
        },
        "blogPost": [
          {
            "@type": "BlogPosting",
            "headline": "Short Ruby Edition 129",
            "datePublished": "2025-03-31T08:25:31Z",
            "dateModified": "2025-03-31T08:25:31Z",
            "mainEntityOfPage": {
              "@type": "WebPage",
              "@id": "https://notes.ghinda.com/post/short-ruby-edition-129"
            },
            "image": "https://example.com/image.png",
            "url": "https://notes.ghinda.com/post/short-ruby-edition-129",
            "author": {
              "@type": "Person",
              "name": "Short Notes"
            }
          }
        ]
      }
    JSON

    schema = WebAuthor::LdSchema.from_script_tag(script_tag)

    assert_equal 'https://schema.org', schema.context
    assert_equal 'Blog', schema.type
    assert_equal 'Short Notes', schema.name
    assert_equal 'Short posts mostly about Ruby and Ruby on Rails.', schema.description
    assert_equal 'https://notes.ghinda.com', schema.url
    assert_equal 'https://example.com/image.png', schema.image
    assert_equal({ '@type' => 'Person', 'name' => 'Short Notes' }, schema.publisher)

    assert_kind_of Array, schema.blog_post
    assert_equal 1, schema.blog_post.size
    assert_equal 'BlogPosting', schema.blog_post.first['@type']
    assert_equal 'Short Ruby Edition 129', schema.blog_post.first['headline']
    assert_equal 'https://notes.ghinda.com/post/short-ruby-edition-129', schema.blog_post.first['url']
  end
end
