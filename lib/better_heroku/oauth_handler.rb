# frozen_string_literal: true

module BetterHeroku
  class OAuthHandler
    AUTH_HOST = "https://id.heroku.com"

    def initialize(secret:, refresh_token:, client: BetterHeroku::Client.new)
      @secret = secret
      @refresh_token = refresh_token

      @client = client.with(host: AUTH_HOST)
    end

    def refresh_token(&callback)
      response = @client.post("oauth/token", params: params)
      callback.call(response) if block_given?

      response["access_token"]
    end

    private

    def params
      {
        grant_type: "refresh_token",
        refresh_token: @refresh_token,
        client_secret: @secret
      }
    end
  end
end
