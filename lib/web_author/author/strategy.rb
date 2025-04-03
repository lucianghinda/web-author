# typed: strict
# frozen_string_literal: true

module WebAuthor
  module Author
    class Strategy
      extend T::Sig
      extend T::Helpers
      abstract!

      sig { overridable.params(document: Nokogiri::XML::Document).void }
      def initialize(document)
        @document = document
      end

      sig { abstract.returns(T.nilable(String)) }
      def author; end

      private

        sig { overridable.returns(Nokogiri::XML::Document) }
        attr_reader :document
    end
  end
end
