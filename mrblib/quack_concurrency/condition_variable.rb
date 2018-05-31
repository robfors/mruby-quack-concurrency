module QuackConcurrency
  class ConditionVariable
  
    # Creates a new {ConditionVariable} concurrency tool.
    # @return [ConditionVariable]
    def initialize
      @waiting_threads = []
    end
    
    # Returns if any `Threads` are currently waiting.
    # @api private
    # @return [Boolean]
    def any_waiting_threads?
      waiting_threads_count >= 1
    end
    
    # Wakes up all `Threads` currently waiting.
    # @return [self]
    def broadcast
      signal_next until @waiting_threads.empty?
      self
    end
    
    # Gets the currently executing `Thread`.
    # @return [Thread]
    def caller
      Thread.current
    end
    
    # Wakes up the next waiting `Thread`, if any exist.
    # @return [self]
    def signal
      signal_next if @waiting_threads.any?
      self
    end
    
    # Wakes up the next waiting `Thread`.
    # Will try again if the `Thread` has already been woken.
    # @api private
    # @return [void]
    def signal_next
      begin
        next_waiting_thread = @waiting_threads.shift
        next_waiting_thread.run if next_waiting_thread
      rescue ThreadError
        # Thread must be dead
        redo
      end
      nil
    end
    
    # Sleeps the current `Thread`.
    # @param duration [nil, Numeric] time to sleep in seconds
    # @api private
    # @return [void]
    def sleep(duration)
      if duration == nil || duration == Float::INFINITY
        Thread.stop
      else
        Thread.sleep(duration)
      end
      nil
    end
    
    # Sleeps the current `Thread` until {#signal} or {#broadcast} wake it.
    # If a {Mutex} is given, the {Mutex} will be unlocked before sleeping and relocked when woken.
    # @raise [ArgumentError]
    # @param mutex [nil,Mutex]
    # @param timeout [nil,Numeric] maximum time to wait, specified in seconds
    # @return [self]
    def wait(mutex = nil, timeout = nil)
      if mutex != nil && (!mutex.respond_to?(:lock) || !mutex.respond_to?(:unlock))
        raise ArgumentError, "'mutex' must respond to 'lock' and 'unlock'"
      end
      if timeout != nil && !timeout.is_a?(Numeric)
        raise ArgumentError, "'timeout' argument must be nil or a Numeric"
      end
      @waiting_threads.push(caller)
      if mutex
        if mutex.respond_to?(:unlock!)
          mutex.unlock! { sleep(timeout) }
        else
          mutex.unlock
          sleep(timeout)
          mutex.lock
        end
      else
        sleep(timeout)
      end
      @waiting_threads.delete(caller)
      self
    end
    
    # Returns the number of `Thread`s currently waiting.
    # @api private
    # @return [Integer]
    def waiting_threads_count
      @waiting_threads_sleepers.length
    end
    
  end
end
