# based off https://en.wikipedia.org/wiki/Reentrant_mutex


module QuackConcurrency
  class ReentrantMutex < Mutex
  
    # Creates a new {ReentrantMutex} concurrency tool.
    # @return [ReentrantMutex]
    def initialize
      super
      @lock_depth = 0
    end
    
    # @api private
    def base_depth(&block)
      start_depth = @lock_depth
      @lock_depth = 1
      yield
    ensure
      @lock_depth = start_depth
    end
    
    # Locks this {ReentrantMutex}.
    # Will block until available.
    # @return [void]
    def lock(&block)
      if block_given?  
        lock
        start_depth = @lock_depth
        start_owner = owner
        begin
          yield
        ensure
          unless @lock_depth == start_depth && owner == start_owner
            raise Error, 'could not unlock reentrant mutex as its state has been modified'
          end
          unlock
        end
      else
        super unless owned?
        @lock_depth += 1
      end
      nil
    end
    
    # Checks if this {ReentrantMutex} is locked by a Thread other than the caller.
    # @return [Boolean]
    def locked_out?
      locked? && !owned?
    end
    
    # Releases the lock and sleeps.
    # When the calling Thread is next woken up, it will attempt to reacquire the lock.
    # @param timeout [Integer] seconds to sleep, `nil` will sleep forever
    # @raise [Error] if this {ReentrantMutex} wasn't locked by the calling Thread
    # @return [void]
    def sleep(timeout = nil)
      raise Error, 'can not unlock reentrant mutex, it is not locked' if locked?
      raise Error, 'can not unlock reentrant mutex, caller is not the owner' unless owned?
      base_depth do
        super(timeout)
      end
    end
    
    # Obtains a lock, runs the block, and releases the lock when the block completes.
    # @return [Object] value from yielded block
    def synchronize
      lock(&block)
    end
    
    # Attempts to obtain the lock and returns immediately.
    # @return [Boolean] returns if the lock was granted
    def try_lock
      if locked_out?
        false
      else
        lock
        true
      end
    end
    
    # Releases the lock.
    # @raise [Error] if {ReentrantMutex} wasn't locked by the calling Thread
    # @return [void]
    def unlock(&block)
      raise Error, 'can not unlock reentrant mutex, it is not locked' if locked?
      raise Error, 'can not unlock reentrant mutex, caller is not the owner' unless owned?
      if block_given?
        unlock
        begin
          yield
        ensure
          lock
        end
      else
        @lock_depth -= 1
        super if @lock_depth == 0
      end
      nil
    end
    
    # Releases the lock.
    # @raise [Error] if {ReentrantMutex} wasn't locked by the calling Thread
    # @return [void]
    def unlock!(&block)
      raise Error, 'can not unlock reentrant mutex, it is not locked' if locked?
      raise Error, 'can not unlock reentrant mutex, caller is not the owner' unless owned?
      if block_given?
        base_depth do
          unlock
          begin
            yield
          ensure
            lock
          end
        end
      else
        @lock_depth = 0
        super
      end
      nil
    end
    
  end
end
  
