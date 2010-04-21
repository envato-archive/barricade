require File.dirname(__FILE__) + '/spec_helper'
require 'active_record'
require 'better_locking'

describe BetterLocking do

  before(:suite) do
    ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/spec.log")
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    load(File.dirname(__FILE__) + "/schema.rb")
  end

  class Post < ActiveRecord::Base
  end

  before(:all) do
    @post = Post.create!
    @another_post = Post.create!
  end

  it "should not allow locking inside a transaction" do
    Post.transaction do
      lambda do 
        Post.transaction_with_locks(@post) { }
      end.should raise_error(BetterLocking::LockMustBeOutermostTransaction)
    end
  end

  it "should not allow locking additional objects inside an existing locked transaction" do
    Post.transaction_with_locks(@post) do
      lambda do 
        Post.transaction_with_locks(@another_post) { }
      end.should raise_error(BetterLocking::LockMustBeOutermostTransaction)
    end
  end

  it "should allow locking an object if a lock is already set on that object" do
    Post.transaction_with_locks(@post) do
      lambda do 
        Post.transaction_with_locks(@post) { }
      end.should_not raise_error
    end
  end

  it "should mark an object as locked inside a transaction with locks" do
    lambda { @post.confirm_locked! }.should raise_error(BetterLocking::LockNotHeld)
    Post.transaction_with_locks(@post) do
      lambda { @post.confirm_locked! }.should_not raise_error
    end
    lambda { @post.confirm_locked! }.should raise_error(BetterLocking::LockNotHeld)
  end

  it "should flatten and compact the list of objects to be locked" do
    Post.transaction_with_locks(@post, @another_post) do
      ActiveRecord::Base.locked_objects.should == [@post, @another_post]
    end
    Post.transaction_with_locks([@post, @another_post]) do
      ActiveRecord::Base.locked_objects.should == [@post, @another_post]
    end
    Post.transaction_with_locks([@post, [@another_post]]) do
      ActiveRecord::Base.locked_objects.should == [@post, @another_post]
    end
    Post.transaction_with_locks([@post, nil, @another_post]) do
      ActiveRecord::Base.locked_objects.should == [@post, @another_post]
    end
  end

end
