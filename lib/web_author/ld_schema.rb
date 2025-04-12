# typed: strict
# frozen_string_literal: true

require 'json'

module WebAuthor
  class LdSchema < T::Struct
    extend T::Sig

    AuthorBaseType = T.type_alias { T.any(String, T::Hash[String, T.untyped]) }
    ArrayofAuthors = T.type_alias { T::Array[AuthorBaseType] }
    AuthorType = T.type_alias { T.any(AuthorBaseType, ArrayofAuthors) }

    const :context, T.nilable(T.any(String, T::Hash[String, T.untyped])), default: nil
    const :type, T.nilable(T.any(String, T::Array[String])), default: nil
    const :id, T.nilable(String), default: nil
    const :name, T.untyped, default: nil
    const :description, T.untyped, default: nil
    const :headline, T.untyped, default: nil
    const :url, T.untyped, default: nil
    const :image, T.untyped, default: nil
    const :author, T.nilable(AuthorType), default: nil
    const :publisher, T.nilable(T.any(String, T::Hash[String, T.untyped])), default: nil
    const :blog_post, T.nilable(T::Array[T::Hash[String, T.untyped]]), default: nil
    const :additional_properties, T::Hash[String, T.untyped], default: {}

    ATTRIBUTES = T.let([
      '@context', '@type', '@id', 'name', 'description', 'url', 'image',
      'author', 'headline', 'publisher', 'blogPost'
    ].freeze, T::Array[String])

    sig { params(script_html_tag: String).returns(T.attached_class) }
    def self.from_script_tag(script_html_tag)
      hash = JSON.parse(script_html_tag)
      from_hash(hash)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(T.attached_class) }
    def self.from_hash(hash)
      main_properties = hash.dup.select { |key, _| ATTRIBUTES.include?(key) }
      main_properties['blog_post'] = main_properties.delete('blogPost')
      main_properties.transform_keys! { |it| it.start_with?('@') ? it.sub('@', '').to_sym : it.to_sym }

      additional_properties = hash.dup
      ATTRIBUTES.each { |it| additional_properties.delete(it) }
      additional_properties.transform_keys!(&:to_s)

      new(**main_properties, additional_properties:)
    end

    sig { returns(T.nilable(T.any(LdAuthor, T::Array[LdAuthor]))) }
    def parsed_author
      return @_parsed_author if defined?(@_parsed_author)

      @_parsed_author = T.let(parse_author, T.nilable(T.any(LdAuthor, T::Array[LdAuthor])))
    end

    private

      sig { returns(T.nilable(T.any(LdAuthor, T::Array[LdAuthor]))) }
      def parse_author
        return nil if author.nil?

        case author
        when String, Hash
          topical_author = T.cast(author, AuthorBaseType)
          LdAuthor.from_hash(topical_author)
        when Array
          topical_author = T.cast(author, ArrayofAuthors)
          topical_author.map { |it| LdAuthor.from_hash(it) }
        end
      end
  end
end
