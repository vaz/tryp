require_relative 'lib/tryp'

$logging = true

midi = Tryp::MIDI.new

midi.play 0, 60, 0.5
sleep 1

