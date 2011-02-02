require_relative 'lib/tryp'


spec, bpm, type = ARGV
bpm = bpm ? bpm.to_i : 120
type = type ? type.to_sym : :simple

pr = Tryp::PolyRhythm.new(spec, type, bpm=bpm)

puts pr

begin
  pr.play!
  sleep
rescue SystemExist, Interrupt
  pr.stop!
  pr.midi.close
  raise
end


