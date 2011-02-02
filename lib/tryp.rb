%w(
  tryp/logging
  tryp/note
  tryp/midi
  tryp/timing/timer
  tryp/timing/metronome
  tryp/patterns/polyrhythm
).each { |f| require_relative f }

