# frozen_string_literal: true

require 'zeitwerk'
require 'nokogiri'
require 'sorbet-runtime'
require 'net/http'
require 'uri'

loader = Zeitwerk::Loader.for_gem
loader.setup

module WebAuthor
  class Error < StandardError; end
end
