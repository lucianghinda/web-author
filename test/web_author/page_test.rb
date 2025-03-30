# frozen_string_literal: true

require 'test_helper'

class PageTest < Minitest::Test
  def test_page_author_returns_value_when_meta_tag_exists
    url = 'http://example.com'
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_equal 'John Doe', page.author
  end

  def test_page_author_returns_nil_when_no_meta_tag_exists
    url = 'http://example.com'
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_nil page.author
  end

  def test_page_author_returns_nil_with_empty_meta_content
    url = 'http://example.com'
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_equal '', page.author
  end

  def test_page_author_returns_nil_with_malformed_meta_tag
    url = 'http://example.com'
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_nil page.author
  end

  def test_page_author_finds_meta_tag_anywhere_in_head
    url = 'http://example.com'
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_equal 'Jane Smith', page.author
  end

  def test_raises_error_on_failed_http_request
    url = 'http://example.com'
    stub_request(:get, url).to_return(status: 404)

    page = WebAuthor::Page.new(url:)

    assert_raises(WebAuthor::Error) { page.author }
  end
end
