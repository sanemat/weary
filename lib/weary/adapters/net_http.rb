require 'net/http'
require 'net/https'

module Weary
  module Adapter
    class NetHttp
      include Weary::Adapter

      def self.call(env)
        perform(env).finish
      end

      def self.perform(env)
        req = Rack::Request.new(env)
        future do
          response = connect(req)
          yield response if block_given?
          response
        end
      end

      def self.connect(request)
        connection = socket(request)
        response = connection.send_request(request.request_method,
                                           request.fullpath,
                                           nil,
                                           normalize_request_headers(request.env))
        Weary::Response.new response.body, response.code, response.to_hash
      end

      def self.normalize_request_headers(env)
        req_headers = env.reject {|k,v| !k.start_with? "HTTP_" }
        Hash[req_headers.map {|k, v| [k.sub("HTTP_",''), v] }]
      end

      def self.socket(request)
        host = request.env['SERVER_NAME']
        port = request.env['SERVER_PORT'].to_s
        connection = Net::HTTP.new host, port
        connection.use_ssl = request.scheme.eql?'https'
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE if connection.use_ssl?
        connection
      end

      def self.headers(response)
        map = {}
        response.each_capitalized do |key, value|
          map[key] = value unless key == 'Status' # Pass Rack::Lint assertions
        end
        map
      end

      def call(env)
        self.class.call(env)
      end

      def perform(env, &block)
        self.class.perform(env, &block)
      end

    end
  end
end