require_relative 'lib/tryp'

midi = Tryp::MIDI.new

midi.note_on 0, 60
sleep 1
midi.note_off 0, 60
sleep 1
midi.program_change 1, 40
midi.note_on 1, 60
sleep 1
midi.note_off 1, 60


midi.play 0, 60, 0.2

