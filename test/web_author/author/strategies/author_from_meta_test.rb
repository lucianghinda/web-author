# frozen_string_literal: true

require 'test_helper'

class WebAuthor::Author::Strategies::AuthorFromMetaTest < Minitest::Test
  def test_page_author_returns_value_when_meta_tag_exists
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="author" content="John Doe">
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)

    author_from_meta = WebAuthor::Author::Strategies::AuthorFromMeta.new(document)

    assert_equal 'John Doe', author_from_meta.author
  end

  def test_page_author_returns_nil_when_no_meta_tag_exists
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

    author_from_meta = WebAuthor::Author::Strategies::AuthorFromMeta.new(document)

    assert_nil author_from_meta.author
  end

  def test_page_author_returns_nil_with_empty_meta_content
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="author" content="">
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)

    author_from_meta = WebAuthor::Author::Strategies::AuthorFromMeta.new(document)

    assert_equal '', author_from_meta.author
  end

  def test_page_author_returns_nil_with_malformed_meta_tag
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="author">
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)

    author_from_meta = WebAuthor::Author::Strategies::AuthorFromMeta.new(document)

    assert_nil author_from_meta.author
  end

  def test_page_author_finds_meta_tag_anywhere_in_head
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>Test Page</title>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <meta name="author" content="Jane Smith">
          <link rel="stylesheet" href="styles.css">
        </head>
        <body>
          <h1>Test Page</h1>
        </body>
      </html>
    HTML

    document = Nokogiri::HTML(html_content)

    author_from_meta = WebAuthor::Author::Strategies::AuthorFromMeta.new(document)

    assert_equal 'Jane Smith', author_from_meta.author
  end
end
