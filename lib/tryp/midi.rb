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

    def initialize(bpm=120)
      @interval = 60.0 / bpm
      @timer = Timer.get(@interval/10)
      open
    end

    def play(channel, note, duration, velocity=100, time=nil)
      on_time = time || Time.now.to_f
      @timer.at(on_time){ note_on channel, note, velocity }

      off_time = on_time + duration
      @timer.at(off_time){ note_off channel, note, velocity }
    end

    def note_on(channel, note, velocity=100)
      message ON | channel, note, velocity
    end

    def note_off(channel, note, velocity=100)
      message OFF | channel, note, velocity
    end

    def program_change(channel, preset)
      message PC | channel, preset
    end
  end
end
