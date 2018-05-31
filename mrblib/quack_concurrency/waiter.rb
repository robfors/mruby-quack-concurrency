module QuackConcurrency
  class Waiter
  
    # Creates a new {Waiter} concurrency tool.
    # @return [Waiter]
    def initialize
      @condition_variable = UninterruptibleConditionVariable.new
      @resume_all_forever = false
    end
    
    # Resumes all current and future waiting thread.
    # @return [void]
    def resume_all
      @condition_variable.broadcast
      nil
    end
    
    # Resumes all current and future waiting thread.
    # @return [void]
    def resume_all_forever
      @resume_all_forever = true
      resume_all
      nil
    end
    
    # Resumes next waiting thread if one exists.
    # @return [void]
    def resume_one
      @condition_variable.signal
      nil
    end
    
    # Waits for another thread to resume the calling thread.
    # @note Will block until resumed.
    # @return [void]
    def wait
      return if @resume_all_forever
      @condition_variable.wait
      nil
    end
    
    def waiting_count
      @condition_variable.waiting_threads_count
    end
    
    def any_waiting?
      @condition_variable.any_waiting_threads?
    end
    
  end
end
