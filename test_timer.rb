require_relative 'lib/tryp'

timer = Tryp::Timer.new(0.01)
timer.at(Time.now + 1) { puts 'hello' }
timer.wait
