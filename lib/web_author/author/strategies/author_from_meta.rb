# typed: strict
# frozen_string_literal: true

module WebAuthor
  module Author
    module Strategies
      class AuthorFromMeta < Strategy
        sig { override.returns(T.nilable(String)) }
        def author
          meta_author = document.at_css('meta[name="author"]')
          meta_author&.attribute('content')&.value
        end
      end
    end
  end
end
