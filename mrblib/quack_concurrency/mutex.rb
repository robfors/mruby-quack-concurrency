module QuackConcurrency
  class Mutex
    
    # Creates a new {Mutex} concurrency tool.
    # @return [Mutex]
    def initialize
      @waiter = Waiter.new
      @owner = nil
    end
    
    #@overload lock
    #  Obtains the lock or sleeps the current `Thread` until it is available.
    #  @raise [ThreadError] if current `Thread` is already locking it
    #  @return [self]
    #@overload lock(&block)
    #  Obtains the lock, runs the block, then releases the lock when the block completes.
    #  @yield block to run with the lock
    #  @return [Object] result of the block
    def lock(&block)
      if block_given?
        lock
        begin
          yield
        ensure
          unlock
        end
      else
        if locked?
          raise ThreadError, 'this Thread is already locking this Mutex' if owned?
          @waiter.wait
        end
        @owner = caller
        nil
      end
    end
    
    def locked?
      !!@owner
    end
    
    def owned?
      @owner == caller
    end
    
    def owner
      @owner
    end
    
    def sleep(timeout = nil)
      if timeout != nil && !timeout.is_a?(Numeric)
        raise ArgumentError, "'timeout' argument must be nil or a Numeric"
      end
      unlock do
        if timeout
          elapsed_time = Kernal.sleep(timeout)
        else
          elapsed_time = Kernal.sleep
        end
      end
      elapsed_time
    end
    
    def synchronize(&block)
      lock(&block)
    end
    
    def try_lock
      if locked?
        false
      else
        lock
        true
      end
    end
    
    def unlock(&block)
      if block_given?
        unlock
        begin
          yield
        ensure
          lock
        end
      else
        raise ThreadError, 'Mutex is not locked' unless locked?
        raise ThreadError, 'current Thread is not locking the Mutex' unless owned?
        if @waiter.any_waiting?
          @waiter.resume_one
          
          # we do this to avoid a bug
          # consider what would happen if we set this to nil and then another thread called #lock
          #   before the resuming thread was able to set itself at the owner in #lock
          @owner = true
        else
          @owner = nil
        end
        nil
      end
    end
    
    private
    
    def caller
      Thread.current
    end
    
  end
end
