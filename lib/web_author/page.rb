# frozen_string_literal: true

module WebAuthor
  class Page
    attr_reader :url, :page_content

    def initialize(url:)
      @url = url
      @page_content = nil
    end

    def author
      fetch_page_content unless page_content

      meta_author = page_content.at_css('meta[name="author"]')
      meta_author&.attribute('content')&.value
    end

    private

      def fetch_page_content
        uri = URI.parse(url)
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          @page_content = Nokogiri::HTML(response.body)
        else
          raise Error, "Failed to fetch page: #{response.code} #{response.message}"
        end
      end
  end
end
