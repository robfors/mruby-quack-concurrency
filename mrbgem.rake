MRuby::Gem::Specification.new('esruby-quack-concurrency') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Rob Fors'
  spec.summary = "Concurrency tools that will tolerate duck types of some of Ruby's core classes."
  spec.version = '0.0.0'
  
  spec.rbfiles = []
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/condition_variable.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/error.rb"
  spec.rbfiles << "#{dir}/mrblib/closed_queue_error.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/future.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/mutex.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/queue.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/reentrant_mutex.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/uninterruptible_condition_variable.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/uninterruptible_sleeper.rb"
  spec.rbfiles << "#{dir}/mrblib/quack_concurrency/waiter.rb"
  spec.rbfiles << "#{dir}/mrblib/setup.rb"
  
end
