module BetterLocking 

  def self.included(base)
    base.extend(ClassMethods)
  end

  def confirm_lock!
    raise LockNotHeld unless ActiveRecord::Base.locked_objects.include?(self)
  end
    
  module ClassMethods
    def transaction_with_locks(*objects)
      objects = objects.flatten.compact
      return if objects.all? {|object| ActiveRecord::Base.locked_objects.include?(object) }

      minimum_transaction_level = (Rails.env.test? ? 1 : 0)
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

    def locked_objects=(objects)
      @locked_objects = objects
    end

    def locked_objects
      @locked_objects || []
    end
  end

  class LockMustBeOutermostTransaction < RuntimeError
  end

  class LockNotHeld < RuntimeError
  end

  class RetryTransaction < RuntimeError
  end

end

class ActiveRecord::Base
  include BetterLocking
end
