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
        url: full_path(path),
        callback: block,
        method: :get,
        options: options
    end

    def post(path, options = {}, &block)
       @actions_stack.push \
        url: full_path(path),
        callback: block,
        method: :post,
        options: options
    end

    def full_path(path)
      path =~ /^https?:\/\// ? path : root_url + path
    end

    def run
      while not @actions_stack.empty?
        action = @actions_stack.shift
        distpach action
      end
    end

    private
      def distpach(action)
        method = action.delete(:method)

        case method
        when :get
          Page.new(@client.get_content(action[:url]))
        when :post
        end
      end

  end
end
