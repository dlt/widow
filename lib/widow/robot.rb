module Widow
  module Robot

    attr_reader :root_url

    attr_reader :actions_stack

    def initialize(options = {})
      @root_url = options.delete(:root_url)
      @client   = HTTPClient.new
      @actions_stack = []
    end

    def get(path, options = {}, &block)
      @actions_stack.push \
        path: full_path(path),
        callback: block,
        method: :get,
        options: options
    end

    def post(path, options = {}, &block)
       @actions_stack.push \
        path: full_path(path),
        callback: block,
        method: :post,
        options: options
    end

    def full_path(path)
      path.match(/^https?:\/\//) ? path : root_url + path
    end

  end

  class Page
    attr_reader :raw, :parsed

    def initialize(raw)
      @raw = raw
      @parsed = Nokogiri::HTML(raw.dup)
    end
  end
end
