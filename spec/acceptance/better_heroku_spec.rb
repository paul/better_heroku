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


  it "should be mockable"

end


