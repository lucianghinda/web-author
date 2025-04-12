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

  def test_page_author_returns_value_when_ld_schema_exists
    url = 'http://example.com'
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "author": {
                "@type": "Person",
                "name": "Jane Smith"
              }
            }
          </script>
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

  def test_page_author_returns_value_from_ld_schema_when_both_meta_and_ld_schema_exist
    url = 'http://example.com'
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="author" content="John Doe">
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "author": {
                "@type": "Person",
                "name": "Jane Smith"
              }
            }
          </script>
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

  def test_page_author_returns_value_when_multiple_authors_in_ld_schema_exist
    url = 'http://example.com'
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Article",
              "author": [
                {
                  "@type": "Person",
                  "name": "Jane Smith"
                },
                {
                  "@type": "Person",
                  "name": "Bob Johnson"
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

    stub_request(:get, url).to_return(body: html_content, status: 200)

    page = WebAuthor::Page.new(url:)

    assert_equal 'Jane Smith, Bob Johnson', page.author
  end

  def test_page_author_returns_nil_when_no_author_info_exists
    url = 'http://example.com'
    html_content = <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
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

  def test_raises_error_on_failed_http_request
    url = 'http://example.com'
    stub_request(:get, url).to_return(status: 404)

    page = WebAuthor::Page.new(url:)

    assert_raises(WebAuthor::Error) { page.author }
  end
end
