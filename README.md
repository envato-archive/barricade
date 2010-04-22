Barricade
=========

Better locking for ActiveRecord.


Installation
------------

    gem install barricade
    
Don’t forget to add it to your environment.rb or Gemfile.
    

Usage
-----

ActiveRecord provides the `lock!` method, but it's not very robust
for anything beyond really simple locks.

This plugin provides a couple of useful methods:

    Post.transaction_with_locks(post, user) do
      ...
    end

This starts a new transaction, and immediately locks all the passed
in objects.

The transaction *MUST* be the outermost transaction, not a nested
transaction, otherwise `transaction_with_locks` will raise a
`Barricade::LockMustBeOutermostTransaction` exception.

It sorts the locked objects before locking, to help avoid deadlocks. If a
deadlock does occur, it retries the locks and continues with the
transaction.

Within the transaction block, you can raise a
`Barricade::RetryTransaction` exception to retry the transaction
from the beginning and make sure all the locks are in place.

You can double-check that you have a lock on an object by calling
its `confirm_locked!` method. This raises a `Barricade::LockNotHeld`
exception if you don't have the lock.

It's safe to re-acquire a lock inside an existing transaction, so
the following will work:

    Post.transaction_with_locks(post) do
      Post.transaction_with_locks(post) do
        ...
      end
    end

but this will raise an exception:

    Post.transaction_with_locks(post) do
      Post.transaction_with_locks(user) do
        ...
      end
    end
     

Background
----------

There are a few things you need to know to understand the difficulty of
using ActiveRecord for locking.

InnoDB is pretty good at detected and flagging deadlocks.
(See [Deadlock Detection and Rollback](http://dev.mysql.com/doc/refman/5.1/en/innodb-deadlock-detection.html))

Any attempt to grab an exclusive lock on a record can result in a
deadlock, and a deadlock causes a couple of things to happen:

1. MySQL will roll back the outermost current transaction.

2. ActiveRecord will throw a `ActiveRecord::StatementInvalid` exception

The end result is that your ActiveRecord objects may end up out of sync
with their corresponding database records.

Barricade avoids this by doing all the locking at the very start of
the transaction. A deadlock when grabbing the locks will cause an
immediate retry, before any code that has side effects can be run.

The downside is that you have to do your locking in the outermost
transaction, which can make it difficult to encapsulate logic in
your model without placing restrictions on where your model can be
called from.


Credits
-------

Copyright &copy; 2010 [Envato](http://envato.com).
Initially developed by [Pete Yandell](http://notahat.com).
Released under an MIT license.
