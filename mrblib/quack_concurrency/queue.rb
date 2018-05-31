module QuackConcurrency
  
  # @note duck type for `::Thread::Queue`
  class Queue
  
    # Creates a new {Queue} concurrency tool.
    # @return [Queue]
    def initialize
      @waiter = Waiter.new
      @items = []
      @closed = false
    end
    
    # Removes all objects from the queue.
    # @return [self]
    def clear
      @items.clear
      self
    end
    
    # Closes the queue. A closed queue cannot be re-opened.
    # After the call to close completes, the following are true:
    # * {#closed?} will return `true`.
    # * {#close} will be ignored.
    # * {#push} will raise an exception.
    # * until empty, calling {#pop} will return an object from the queue as usual.
    # @return [self]
    def close
      return if closed?
      @closed = true
      @waiter.resume_all
      self
    end
    
    # Checks if queue is closed.
    # @return [Boolean]
    def closed?
      @closed
    end
    
    # Checks if queue is empty.
    # @return [Boolean]
    def empty?
      @items.empty?
    end
    
    # Returns the length of the queue.
    # @return [Integer]
    def length
      @items.length
    end
    alias_method :size, :length
    
    # Returns the number of threads waiting on the queue.
    # @return [Integer]
    def num_waiting
      @waiter.waiting_threads_count
    end
    
    # Retrieves item from the queue.
    # @note If the queue is empty, it will block until an item is available.
    #   If `non_block` is true, it will raise {Error} instead.
    # @raise {Error} if queue is empty and `non_block` is true
    # @param non_block [Boolean] 
    def pop(non_block = false)
      if num_waiting >= length
        return if closed?
        raise ThreadError if non_block
        @waiter.wait
        return if closed?
      else
        Thread.pass # so all the callers will pop in the order they called
      end
      @items.shift
    end
    alias_method :deq, :pop
    alias_method :shift, :pop
    
    # Pushes the given object to the queue.
    # @return [self]
    def push(item = nil)
      raise ClosedQueueError if closed?
      @items.push(item)
      @waiter.resume_one
      self
    end
    alias_method :<<, :push
    alias_method :enq, :push
    
  end
end
