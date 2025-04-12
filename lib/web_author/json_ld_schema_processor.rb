# typed: strict
# frozen_string_literal: true

require 'json'

module WebAuthor
  class JsonLdSchemaProcessor
    extend T::Sig

    JSON_LD_SCHEMA_XPATH = '//script[@type="application/ld+json"]'

    sig { params(document: Nokogiri::XML::Document).void }
    def initialize(document:)
      @document = T.let(document, Nokogiri::XML::Document)
      @_schemas = T.let(nil, T.nilable(T::Array[LdSchema]))
    end

    sig { returns(T::Array[LdSchema]) }
    def schemas
      @_schemas ||= extract_schemas
    end

    private

      sig { returns(Nokogiri::XML::Document) }
      attr_reader :document

      sig { returns(T::Array[LdSchema]) }
      def extract_schemas
        json_ld_script_tags.filter_map do |script_tag|
          content = script_tag.content.strip
          next if content.empty?

          json_data = JSON.parse(content)
          LdSchema.from_hash(json_data)
        rescue JSON::ParserError
          # Skip invalid JSON as we don't need to process it but we want to
          # let the processing move on to the next script tag that is JSON-LD
          nil
        end
      end

      sig { returns(Nokogiri::XML::NodeSet) }
      def json_ld_script_tags = document.xpath(JSON_LD_SCHEMA_XPATH)
  end
end
