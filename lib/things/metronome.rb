

module Tryp
  class Metronome
    def initialize(bpm)
      @midi = MIDI.new
      @midi.program_change 0, 115 # wood block or something
      @interval = 60.0 / bpm
      @timer = Timer.new(@interval/10)
      @which_bang = 0
      now = Time.now.to_f
      register_next_bang(now)
    end

    def register_next_bang(time)
      @timer.at time do
        now = Time.now.to_f
        register_next_bang now + @interval
        bang
      end
    end

    def bang
      note = @which_bang == 0 ? 84 : 74
      @midi.note_on 0, note
      sleep 0.1
      @midi.note_off 0, note
      @which_bang = (@which_bang + 1) % 4
    end
  end
end

