# mruby Quack Concurrency
This mruby gem offers a few concurrency tools that could also be found in [*Concurrent Ruby*](https://github.com/ruby-concurrency/concurrent-ruby). However, all of *Quack Concurrency's* tools will tolerate duck types of Ruby's core classes to adjust the blocking behaviour of the tools. The tools include: `Future`, `Queue`, `ReentrantMutex`, `Semaphore` and `Waiter`. Each tool will accept duck types for `Thread` and `Kernel`. *TODO: list some projects useing it*.
