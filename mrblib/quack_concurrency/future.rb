module QuackConcurrency
  class Future
    
    # Creates a new {Future} concurrency tool.
    # @return [Future]
    def initialize
      @waiter = Waiter.new
      @value = nil
      @complete = false
      @exception = nil
    end
    
    # Cancels the {Future}.
    # Calling {#get} will result in Canceled being raised.
    # Same as `raise(Canceled.new)`.
    # @raise [Complete] if the {Future} was already completed
    # @param exception [Exception] custom `Exception` to set
    # @return [void]
    def cancel(exception = nil)
      exception ||= Canceled.new
      raise(exception)
      nil
    end
    
    # Checks if {Future} has a value or was canceled.
    # @return [Boolean]
    def complete?
      @complete
    end
    
    # Gets the value of the {Future}.
    # @note This method will block until the future has completed.
    # @raise [Canceled] if the {Future} is canceled
    # @return [Object] value of the {Future}
    def get
      @waiter.wait
      raise @exception if @exception
      @value
    end
    
    # Cancels the {Future} with a custom `Exception`.
    # @raise [Complete] if the future has already completed
    # @param exception [Exception]
    # @return [void]
    def raise(exception = nil)
      unless exception == nil || exception.is_a?(Exception)
        raise ArgumentError, "'exception' must be nil or an instance of an Exception"
      end
      raise Complete if @complete
      @complete = true
      @exception = exception || StandardError.new
      @waiter.resume_all_forever
      nil
    end
    
    # Sets the value of the {Future}.
    # @raise [Complete] if the {Future} has already completed
    # @param new_value [nil,Object] value to assign to future
    # @return [void]
    def set(new_value = nil)
      raise Complete if @complete
      @complete = true
      @value = new_value
      @waiter.resume_all_forever
      nil
    end
    
  end
end
