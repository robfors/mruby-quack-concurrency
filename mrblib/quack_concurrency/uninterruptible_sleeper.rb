module QuackConcurrency
  class UninterruptibleSleeper
    
    def self.for_current
      new(Thread.current)
    end
    
    def initialize(thread)
      raise ArgumentError, "'thread' must be a Thread" unless thread.is_a?(Thread)
      @thread = thread
      @state = :running
      @stop_called = false
      @run_called = false
    end
    
    # @api private
    def current?
      Thread.current == @thread
    end
    
    def run_thread
      raise '#run_thread has already been called once' if @run_called
      @run_called = true
      return if @state == :running
      @state = :running
      @thread.run
      nil
    end
    
    def sleep_thread(duration)
      start_time = Time.now
      stop_thread(duration)
      time_elapsed = Time.now - start_time
    end
    
    def stop_thread(timeout = nil)
      raise 'can only stop current Thread' unless current?
      raise "'timeout' argument must be nil or a Numeric" if timeout != nil && !timeout.is_a?(Numeric)
      raise '#stop_thread has already been called once' if @stop_called
      @stop_called = true
      target_end_time = Time.now + timeout
      return if @run_called
      @state = :sleeping
      loop do
        if timeout
          time_left = target_end_time - Time.now
          Kernel.sleep(time_left) if time_left > 0
        else
          Thread.stop
        end
        redo unless @state == :running || Time.now >= target_time
      end
      @state = :running
      nil
    end
    
  end
end
