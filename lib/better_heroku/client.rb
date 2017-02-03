require "http"

module BetterHeroku
  class Client
    ACCEPT = "application/vnd.heroku+json; version=3"

    attr_reader :host, :http

    def initialize(host: "https://api.heroku.com", http: HTTP)
      @host = host
      @http = http.headers("Accept" => ACCEPT)
    end

    def get(*parts)
      path = [host, *parts].join("/")
      http.get(path)
    end

    def authenticate(token: token)
      branch http.auth("Bearer #{token}")
    end

    private

    def branch(http)
      self.class.new http: http
    end
  end
end
