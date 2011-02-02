

module Tryp
  class Pattern
    def initialize pattern_string
      @pattern = pattern_string
      @i = 0
    end

    def next
      c = @pattern[@i]
      @i = (@i + 1) % @pattern.length
      c
    end

    def to_s
      @pattern
    end
  end

  class PolyRhythm
    attr_reader :timer
    attr_reader :spec
    attr_accessor :channel
    attr_accessor :midi

    def initialize spec, strategy, bpm=120, channel=0, note1=:C3, note2=:C2
      x, y = spec.split(':').map &:to_i
      lcm = x.lcm(y)
      one, two = ['-'] * x, ['-'] * y
      if strategy == :simple
        one[0] = 'x'
        two[0] = 'x'
      elsif strategy == :interesting
        one[0] = 'x'
        two[0] = 'x'
        one[(x/2)] = 'x'
      elsif strategy == :weird
        one[0] = 'x'
        two[0] = 'x'
        one[(x/2)] = 'x'
        two[(y/2)] = 'x'
      end
      one = one * (lcm/x)
      two = two * (lcm/y)
      one = one.join('')
      two = two.join('')

      @patterns = [Pattern.new(one), Pattern.new(two)]
      @notes = [note1, note2]
      @spec = spec
      @beats_per_bar = lcm
      @midi = MIDI.new(bpm)
      @interval = (60.0 / bpm) * [x,y].max / lcm 
      @timer = Timer.get(@interval/100)
      @channel = channel
      @playing = false
    end

    def play!
      @playing = true
      register_next_bang Time.now.to_f
    end

    def stop!
      @playing = false
    end

    def register_next_bang time
      @timer.at time do |this_time|
        if @playing
          register_next_bang this_time + @interval
          bang!
        end
      end
    end

    def bang!
      one, two = @patterns.map &:next
      if one == 'x'
        @midi.play @channel, @notes[0], 0.1, 100, Time.now.to_f + 0.1
      end
      if two == 'x'
        @midi.play @channel, @notes[1], 0.1, 100, Time.now.to_f + 0.1
      end
    end

    def to_s
      (@patterns.map &:to_s).join("\n")
    end
  end
end
