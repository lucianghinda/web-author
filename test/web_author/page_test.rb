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

  def test_raises_error_on_failed_http_request
    url = 'http://example.com'
    stub_request(:get, url).to_return(status: 404)

    page = WebAuthor::Page.new(url:)

    assert_raises(WebAuthor::Error) { page.author }
  end
end
