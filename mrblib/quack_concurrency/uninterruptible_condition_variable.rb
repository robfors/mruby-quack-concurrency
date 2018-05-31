module QuackConcurrency
  class UninterruptibleConditionVariable
  
    def initialize
      @waiting_threads_sleepers = []
    end
    
    def any_waiting_threads?
      waiting_threads_count >= 1
    end
    
    def broadcast
      signal_next until @waiting_threads_sleepers.empty?
      self
    end
    
    def signal
      signal_next if @waiting_threads_sleepers.any?
      self
    end
    
    # @api private
    def signal_next
      next_waiting_thread_sleeper = @waiting_threads_sleepers.shift
      next_waiting_thread_sleeper.run_thread if next_waiting_thread_sleeper
      nil
    end
    
    # @api private
    def sleep(sleeper, duration)
      if duration == nil || duration == Float::INFINITY
        sleeper.stop_thread
      else
        sleeper.sleep_thread(timeout)
      end
      nil
    end
    
    def wait(mutex = nil, timeout = nil)
      if mutex != nil && (!mutex.respond_to?(:lock) || !mutex.respond_to?(:unlock))
        raise "'mutex' must respond to 'lock' and 'unlock'"
      end
      raise "'timeout' argument must be nil or a Numeric" if timeout != nil && !timeout.is_a?(Numeric)
      sleeper = UninterruptibleSleeper.for_current
      @waiting_threads_sleepers.push(sleeper)
      if mutex
        if mutex.respond_to?(:unlock!)
          mutex.unlock! { sleep(sleeper, timeout) }
        else
          mutex.unlock
          sleep(sleeper, timeout)
          mutex.lock
        end
      else
        sleep(sleeper, timeout)
      end
      @waiting_threads_sleepers.delete(sleeper)
      self
    end
    
    def waiting_threads_count
      @waiting_threads_sleepers.length
    end
    
  end
end
