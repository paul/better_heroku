# frozen_string_literal: true

module BetterHeroku
  # Gem identity information.
  module Identity
    def self.name
      "better_heroku"
    end

    def self.label
      "BetterHeroku"
    end

    def self.version
      "0.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end
  end
end
