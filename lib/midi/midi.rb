if RUBY_PLATFORM.include? 'darwin'
  require_relative 'coremidi'
elsif RUBY_PLATFORM.include? 'linux'
  require_relative 'alsa'
elsif RUBY_PLATFORM.include? 'mswin'
  require_relative 'winmm'
else
  raise "No MIDI support for #{RUBY_PLATFORM}"
end

module Tryp
  class MIDI
    ON  = 0x90
    OFF = 0x80
    PC  = 0xc0

    def initialize
      open
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
