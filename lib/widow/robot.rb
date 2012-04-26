require 'celluloid'
require 'logger'

module Widow
  # The main module. Every new robot should include the Robot module.
  #
  # It will handle most of the basic crawling activity like logging, 
  # scheduling the requests and parsing the robots.txt file. 
  #
  # More documentation about this as development keeps going.
  module Robot

    # Automaticaly includes the Celluloid module
    # in the base object
    #
    def self.included(base)
      base.send :include, Celluloid
    end

    attr_reader :root_url

    attr_reader :actions_stack

    attr_reader :timer

    def initialize(config = {})
      unless config[:interval_between_requests]
        raise ArgumentError, "Set required option :interval_between_requests"
      end

      @config = config
      @root_url = config.delete(:root_url)
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
      @timer = after(@config[:interval_between_requests]) do
        unless @actions_stack.empty?
          action = @actions_stack.shift
          dispatch action
        end
      end
    end

    private
      def dispatch(action)
        method = action.delete(:method)

        case method
        when :get
          Page.new @client.get_content(action[:url])
        when :post
        end
      end

  end
end
