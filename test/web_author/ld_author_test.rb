# frozen_string_literal: true

require 'test_helper'

class WebAuthor::LdAuthorTest < Minitest::Test
  def test_initializes_with_name
    author = WebAuthor::LdAuthor.new(name: 'John Doe')

    assert_equal 'John Doe', author.name
    assert_nil author.type
    assert_nil author.url
    assert_empty(author.additional_properties)
  end

  def test_initializes_with_all_properties
    author = WebAuthor::LdAuthor.new(
      type: 'Person',
      name: 'John Doe',
      url: 'https://example.com/john',
      additional_properties: { 'jobTitle' => 'Writer' }
    )

    assert_equal 'Person', author.type
    assert_equal 'John Doe', author.name
    assert_equal 'https://example.com/john', author.url
    assert_equal({ 'jobTitle' => 'Writer' }, author.additional_properties)
  end

  def test_from_hash_with_string
    author = WebAuthor::LdAuthor.from_hash('John Doe')

    assert_equal 'John Doe', author.name
    assert_nil author.type
    assert_nil author.url
    assert_empty(author.additional_properties)
  end

  def test_from_hash_with_hash
    hash = {
      '@type' => 'Person',
      'name' => 'John Doe',
      'url' => 'https://example.com/john'
    }

    author = WebAuthor::LdAuthor.from_hash(hash)

    assert_equal 'Person', author.type
    assert_equal 'John Doe', author.name
    assert_equal 'https://example.com/john', author.url
    assert_empty(author.additional_properties)
  end

  def test_from_hash_with_additional_properties
    hash = {
      '@type' => 'Person',
      'name' => 'John Doe',
      'url' => 'https://example.com/john',
      'jobTitle' => 'Writer',
      'affiliation' => 'Example Inc.'
    }

    author = WebAuthor::LdAuthor.from_hash(hash)

    assert_equal 'Person', author.type
    assert_equal 'John Doe', author.name
    assert_equal 'https://example.com/john', author.url
    assert_equal({
      'jobTitle' => 'Writer',
      'affiliation' => 'Example Inc.'
    }, author.additional_properties)
  end

  def test_author_with_image_url_and_same_as
    hash = {
      '@type' => 'Person',
      'name' => 'John Doe',
      'url' => 'https://example.com/john',
      'jobTitle' => 'Writer',
      'image' => {
        '@type' => 'ImageObject',
        'url' => 'https://example.com/john/image.jpg',
        'sameAs' => 'https://example.com/john/image.jpg'
      },
      sameAs: ['https:/bsky.app/profile/johndoe.com']
    }

    author = WebAuthor::LdAuthor.from_hash(hash)

    assert_equal 'Person', author.type
    assert_equal 'John Doe', author.name
    assert_equal 'https://example.com/john', author.url
    assert_equal(
      {
        'jobTitle' => 'Writer',
        'image' => {
          '@type' => 'ImageObject',
          'url' => 'https://example.com/john/image.jpg',
          'sameAs' => 'https://example.com/john/image.jpg'
        },
        'sameAs' => ['https:/bsky.app/profile/johndoe.com']
      }, author.additional_properties
    )
  end
end
