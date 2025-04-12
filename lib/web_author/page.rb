# frozen_string_literal: true
# typed: strict

module WebAuthor
  class Page
    extend T::Sig

    sig { returns(String) }
    attr_reader :url

    sig { returns(T.nilable(Nokogiri::XML::Document)) }
    attr_reader :page_content

    sig { params(url: String).void }
    def initialize(url:)
      @url = T.let(url, String)
      @page_content = T.let(nil, T.nilable(Nokogiri::XML::Document))
    end

    sig { returns(T.nilable(String)) }
    def author
      fetch_page_content unless page_content

      STRATEGIES.each do |strategy_class|
        author = strategy_class.new(T.must(page_content)).author
        return author if author
      end

      nil
    end

    private

      # The order of these strategies is important as it determines in case of conflicting data
      # which strategy should be used first.
      STRATEGIES = T.let([
        WebAuthor::Author::Strategies::AuthorFromLdSchema,
        WebAuthor::Author::Strategies::AuthorFromMeta
      ].freeze, T::Array[T.class_of(WebAuthor::Author::Strategy)])
      private_constant :STRATEGIES

      sig { returns(T.nilable(Nokogiri::XML::Document)) }
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
