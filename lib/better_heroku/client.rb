require "http"

module BetterHeroku
  class Client
    ACCEPT = "application/vnd.heroku+json; version=3"

    attr_reader :http

    def initialize(host: "https://api.heroku.com/", http: HTTP)
      @http = http.persistent(host).headers("Accept" => ACCEPT)
    end

    def get(*parts)
      path = "/" + parts.join("/")
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
