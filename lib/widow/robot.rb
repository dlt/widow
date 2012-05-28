require 'celluloid'
require 'httpclient'
require 'logger'
require 'pp'

module Widow
  # The main module. Every new robot should include the Robot module.
  #
  # It will handle most of the basic crawling activities like logging, 
  # scheduling the requests and parsing the robots.txt file. 
  #
  # More documentation about this as development keeps going.
  module Robot

    # Automaticaly includes the Celluloid module
    # in the base object.
    #
    def self.included(base)
      base.send :include, Celluloid
    end

    # Base url for HTTP requests.
    #
    attr_reader :root_url

    # HTTP request stack.
    #
    attr_reader :request_stack

    # Celluloid timer used to schedule the requests.
    #
    attr_reader :timer

    def initialize(config = {})
      unless config[:interval_between_requests]
        raise ArgumentError, "Set required option :interval_between_requests"
      end

      @config = config
      @root_url = config.delete(:root_url)

      # TODO: set cookie store
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
      @timer = every(@config[:interval_between_requests]) do
        unless @request_stack.empty?
          request = @request_stack.shift
          dispatch request
        end
      end
    end

    def dispatch(request)
      pp "performin request: #{request.inspect}"

      callback, method, url, params = request.values_at :callback, :method, :url, :parameters

      content = @http_client.send("#{method}_content", url, params)
      page = Page.new(content)

      callback.call(page)
    end

    def full_path(path)
      if path =~ /^https?:\/\// 
        path
      else
        path = ?/ + path unless path.start_with? ?/
        "#{root_url}#{path}"
      end
    end
  end
end
