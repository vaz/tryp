require_relative 'lib/tryp'

$logging = true

midi = Tryp::MIDI.new 140

midi[0].play 60, 0.5
sleep 1
midi.close

