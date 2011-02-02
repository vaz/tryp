if RUBY_PLATFORM.include? 'darwin'
  require_relative 'drivers/coremidi'
elsif RUBY_PLATFORM.include? 'linux'
  require_relative 'drivers/alsa'
elsif RUBY_PLATFORM.include? 'mswin'
  require_relative 'drivers/winmm'
else
  raise "No MIDI support for #{RUBY_PLATFORM}"
end

module Tryp
  class MIDI
    ON  = 0x90
    OFF = 0x80
    PC  = 0xc0

    attr_reader :interval
    attr_reader :timer

    def initialize bpm=120
      @interval = 60.0 / bpm
      @timer = Timer.get(@interval/100)
      open
      log "initializing MIDI system with bpm #{bpm}"
    end

    def [] i
      raise ArgumentError, "channel must be (0..15)" unless (0..15) === i
      @channel ||= Channel.new(self, i)
    end

    def play channel, note, duration, velocity=100, time=nil
      on_time = time || Time.now.to_f
      @timer.at(on_time){ note_on channel, note, velocity }

      off_time = on_time + duration
      @timer.at(off_time){ note_off channel, note, velocity }
      
      log "MIDI#play channel=#{channel} note=#{note} " + 
          "duration=#{duration} velocity=#{velocity} time=#{time}"
    end

    def note_on channel, note, velocity=100
      message ON | channel, note.to_note.value, velocity
    end

    def note_off channel, note, velocity=100
      message OFF | channel, note.to_note.value, velocity
    end

    def program_change channel, preset
      message PC | channel, preset
    end

    class Channel
      def initialize midi_out, channel_number
        unless (0..15) === channel_number
          raise ArgumentError, "channel must be in (0..15)" 
        end
        @out, @channel = midi_out, channel_number
      end

      def play note, duration, velocity=100
        @out.play @channel, note, duration, velocity
      end

      def program_change preset
        @out.program_change @channel, preset
      end
    end
  end
end
