
module BetterHeroku
  class Response
    extend Forwardable

    attr_reader :http_response

    delegate %i[parse status ] => :http_response

    delegate %i[[] each map] => :parse

    def initialize(http_response)
      @http_response = http_response
    end

  end
end
