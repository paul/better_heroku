require "http"

require "better_heroku/oauth_handler"
require "better_heroku/response"
require "better_heroku/null_instrumenter"

module BetterHeroku
  class Client
    ACCEPT = "application/vnd.heroku+json; version=3"
    DEFAULT_HEADERS = {
      "Accept" => ACCEPT
    }

    API_HOST  = "https://api.heroku.com"

    def initialize(host: "https://api.heroku.com", http: HTTP, instrumenter: BetterHeroku::NullInstrumenter.new, **kwargs)
      @options = kwargs
      @options[:host] = host
      @options[:http] = http.headers(DEFAULT_HEADERS)
      @options[:instrumenter] = instrumenter
    end

    def get(*parts, **options)
      request(:get, *parts, **options)
    end

    def post(*parts, **options)
      request(:post, *parts, **options)
    end

    def put(*parts, **options)
      request(:post, *parts, **options)
    end

    def delete(*parts, **options)
      request(:post, *parts, **options)
    end

    def patch(*parts, **options)
      request(:post, *parts, **options)
    end

    def authenticate(token:)
      branch http: http.auth("Bearer #{token}")
    end

    def oauth(secret:, refresh_token:, access_token: nil)
      oauth_handler =
        OAuthHandler.new(secret: secret, refresh_token: refresh_token)
      branch(oauth_handler: oauth_handler).authenticate(token: access_token)
    end

    def refresh_oauth_token(&block)
      access_token = @options[:oauth_handler].refresh_token(&block)

      authenticate(token: access_token)
    end

    private

    def request(verb, *parts, **options)
      path = [host, *parts].join("/")
      instrument(verb, path, options) do |payload|
        Response.new(http.request(verb, path, options)).tap { |resp| payload[:response] = resp }
      end
    end

    def host
      @options[:host]
    end

    def http
      @options[:http]
    end

    def branch(options)
      self.class.new @options.merge(options)
    end

    def instrument(verb, url, options, &block)
      @options[:instrumenter].instrument("request.better_heroku_client", verb: verb, url: url, options: options, &block)
    end
  end
end
