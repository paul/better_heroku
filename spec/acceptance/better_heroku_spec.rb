require "spec_helper"

RSpec.describe BetterHeroku::Client do
  let(:token) { "969b3060-3e37-4939-a4fc-64df51b0cc55" }

  describe "making requests" do
    it "should successfully make a request" do
      client = BetterHeroku::Client.new
      client = client.authenticate(token: token)
      response = client.get("account")
      expect(response.status).to eq 200
      expect(response.parse["id"]).to be_kind_of(String)
    end
  end

  describe "OAuth token exchange" do
    let(:secret)        { ENV.fetch("HEROKU_OAUTH_SECRET") }
    let(:refresh_token) { ENV.fetch("HEROKU_REFRESH_TOKEN") }

    it "should handle the token exchange when token is not provided" do
      client = BetterHeroku::Client.new

      expired_client = client.oauth(secret: secret, refresh_token: refresh_token)

      response = expired_client.get("account")
      expect(response.status).to eq 401

      authed_client = expired_client.refresh_oauth_token do |response|
        expect(response["access_token"]).to_not be_nil
      end

      response = authed_client.get("account")
      expect(response.status).to eq 200
      expect(response.parse["id"]).to be_kind_of(String)
    end

  end

  it "should be mockable"

end


