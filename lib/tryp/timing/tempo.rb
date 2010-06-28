

module Tryp
  class Tempo
    def initialize(bpm=120)
      @bpm = bpm
    end

    def beats_per_minute
      @bpm
    end
    alias :bpm :beats_per_minute

    def beats_per_second
      @bpm / 60.0
    end
    alias :bps :beats_per_second

    def tap!
      # use this for tap tempo
    end

    def to_s
      "#{bpm} bpm"
    end
  end
end

