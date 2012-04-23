require 'nokogiri'

module Widow
  class Page
    attr_reader :raw, :parsed

    def initialize(raw, selectors = {})
      @raw = raw
      @parsed = Nokogiri::HTML(raw.dup)
      setup_selectors(selectors)
    end

    private
      def setup_selectors(selectors)
        selectors.each do |method_name, selector|
          instance_eval %Q{
            def #{method_name}
              @parsed.css("#{selector}")
            end
          }
        end
      end
  end
end
