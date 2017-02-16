module BetterHeroku
  class NullInstrumenter

    def initialize
    end

    def instrument(name, payload = {})
      yield payload if block_given?
    end
  end
end

