# typed: true
# frozen_string_literal: true

module WebAuthor
  class LdAuthor < T::Struct
    extend T::Sig

    const :type, T.nilable(String), default: nil
    const :name, T.nilable(String), default: nil
    const :url, T.nilable(String), default: nil
    const :additional_properties, T::Hash[String, T.untyped], default: {}

    ATTRIBUTES = T.let(['@type', 'name', 'url'].freeze, T::Array[String])

    sig { params(hash: T.any(String, T::Hash[String, T.untyped])).returns(T.attached_class) }
    def self.from_hash(hash)
      return new(name: hash) if hash.is_a?(String)

      main_properties = hash.dup.select { |key, _| ATTRIBUTES.include?(key) }
      main_properties['type'] = main_properties.delete('@type')
      main_properties.transform_keys!(&:to_sym)

      additional_properties = hash.dup
      ATTRIBUTES.each { |it| additional_properties.delete(it) }
      additional_properties.transform_keys!(&:to_s)

      new(**main_properties, additional_properties:)
    end
  end
end
