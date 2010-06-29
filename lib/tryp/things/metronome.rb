

module Tryp
  class Metronome
    attr_reader :timer
    attr_accessor :channel

    def initialize(bpm, channel=0)
      @midi = MIDI.new(bpm)
      @midi.program_change 0, 115 # wood block or something
      @interval = 60.0 / bpm
      @timer = Timer.get(@interval/10)
      @which_bang = 0
      @channel = channel
      now = Time.now.to_f
      register_next_bang now
    end

    def register_next_bang(time)
      @timer.at time do |this_time|
        register_next_bang this_time + @interval
        bang
      end
    end

    def bang
      note = @which_bang == 0 ? 84 : 74
      @midi.play @channel, note, 0.1, 100, Time.now.to_f + 0.2
      @which_bang = (@which_bang + 1) % 4
    end
  end
end

