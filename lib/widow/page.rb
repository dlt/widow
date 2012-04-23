require 'nokogiri'

module Widow
  class Page
    attr_reader :raw, :parsed

    def initialize(raw)
      @raw = raw
      @parsed = Nokogiri::HTML(raw.dup)
    end
  end

end
