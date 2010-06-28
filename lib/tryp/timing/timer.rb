

module Tryp
  class Timer
    def self.get(resolution)
      @timers ||= {}
      return @timers[resolution] if @timers[resolution]
      return @timers[resolution] = self.new(resolution)
    end

    def initialize(resolution)
      @resolution = resolution
      @queue = []

      @thread = Thread.new do
        while true
          dispatch
          sleep(@resolution)
        end
      end
    end

    def at(time, &block)
      time = time.to_f if time.kind_of?(Time)
      @queue.push [time, block]
    end

    def wait
      @thread.join
    end

    private
    def dispatch
      now = Time.now.to_f
      ready, @queue = @queue.partition { |time, proc| time <= now }
      ready.each { |time, proc| proc.call time }
    end
  end
end


