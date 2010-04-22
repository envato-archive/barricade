# Methods defined here are included as instance methods on ActiveRecord::Base.
module Barricade

  def self.configuration #:nodoc:
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    # Set this in your tests if you're using transactional_fixtures, so
    # Barricade will know not to complain about a containing
    # transaction when you call transaction_with_locks.
    attr_accessor :running_inside_transactional_fixtures

    def initialize
      @running_inside_transactional_fixtures = false
    end
  end

  def self.included(base) #:nodoc:
    base.extend(ClassMethods)
  end

  # Confirms that this object has been locked in an enclosing call to
  # transaction_with_locks. Raises LockNotHeld if the lock isn't held.
  def confirm_locked!
    raise LockNotHeld unless ActiveRecord::Base.locked_objects.include?(self)
  end
   
  # Methods defined here are included as class methods on ActiveRecord::Base.
  module ClassMethods
    # Perform a transaction with the given ActiveRecord objects locked.
    #
    # e.g.
    #   Post.transaction_with_locks(post) do
    #     post.comments.create!(...)
    #   end
    def transaction_with_locks(*objects)
      objects = objects.flatten.compact
      return if objects.all? {|object| ActiveRecord::Base.locked_objects.include?(object) }

      minimum_transaction_level = Barricade.configuration.running_inside_transactional_fixtures ? 1 : 0
      raise LockMustBeOutermostTransaction unless connection.open_transactions == minimum_transaction_level
    
      objects.sort_by {|object| [object.class.name, object.send(object.class.primary_key)] }
      begin
        ActiveRecord::Base.locked_objects = nil
        transaction do
          begin
            objects.each(&:lock!)
            ActiveRecord::Base.locked_objects = objects
          rescue ActiveRecord::StatementInvalid => exception
            if exception.message =~ /Deadlock/
              raise RetryTransaction
            else
              raise
            end
          end

          yield
        end
      rescue RetryTransaction
        retry
      ensure
        ActiveRecord::Base.locked_objects = nil
      end
    end

    def locked_objects=(objects) #:nodoc:
      @locked_objects = objects
    end

    def locked_objects #:nodoc:
      @locked_objects || []
    end
  end

  # Raised when transaction_with_locks is called inside an existing transaction.
  class LockMustBeOutermostTransaction < RuntimeError
  end

  # Raised when confirm_locked! is called on an object that's not locked.
  class LockNotHeld < RuntimeError
  end

  # Raise this to retry the current transaction from the beginning.
  class RetryTransaction < RuntimeError
  end

end

module ActiveRecord #:nodoc:
  class Base #:nodoc:#
    include Barricade
  end
end
