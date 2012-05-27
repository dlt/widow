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

    attr_reader :request_stack

    attr_reader :timer

    def initialize(config = {})
      unless config[:interval_between_requests]
        raise ArgumentError, "Set required option :interval_between_requests"
      end

      @config = config
      @root_url = config.delete(:root_url)
      @http_client   = HTTPClient.new
      @request_stack = []
    end

    def get(path, parameters = {}, &block)
      @request_stack.push \
        url: full_path(path),
        callback: block,
        method: :get,
        parameters: parameters
    end

    def post(path, parameters = {}, &block)
       @request_stack.push \
        url: full_path(path),
        callback: block,
        method: :post,
        parameters: parameters
    end

    def run
      @timer = after(@config[:interval_between_requests]) do
        unless @request_stack.empty?
          action = @request_stack.shift
          dispatch action
        end
      end
    end

    def dispatch(action)
      case action[:method]
      when :get
        Page.new @http_client.get_content(action[:url])
      when :post
      end
    end

    def full_path(path)
      path =~ /^https?:\/\// ? path : root_url + path
    end
  end
end
