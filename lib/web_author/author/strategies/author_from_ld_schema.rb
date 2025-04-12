# typed: strict
# frozen_string_literal: true

module WebAuthor
  module Author
    module Strategies
      class AuthorFromLdSchema < Strategy
        extend T::Sig

        sig { override.params(document: Nokogiri::XML::Document).void }
        def initialize(document)
          @_schemas = T.let(nil, T.nilable(T::Array[LdSchema]))
          super
        end

        sig { override.returns(T.nilable(String)) }
        def author
          return nil if schemas.empty?

          all_author_names = author_names
          return nil if all_author_names.empty?

          all_author_names.uniq.join(', ')
        end

        private

          sig { returns(T::Array[LdSchema]) }
          def schemas
            @_schemas ||= JsonLdSchemaProcessor.new(document:).schemas
          end

          sig { returns(T::Array[String]) }
          def author_names
            names = []
            schemas.each do |schema|
              author = schema.parsed_author
              next if author.nil?

              current_names = if author.is_a?(Array)
                                author.filter_map(&:name)
                              else
                                [author.name].compact
                              end

              names.concat(current_names) unless current_names.empty?
            end

            names
          end
      end
    end
  end
end
