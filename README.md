# BetterLocking

Improved locking for ActiveRecord.

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
`BetterLocking::LockMustBeOutermostTransaction` exception.

It sorts the locked objects before locking, to help avoid deadlocks. If a
deadlock does occur, it retries the locks and continues with the
transaction.

Within the transaction block, you can raise a
`BetterLocking::RetryTransaction` exception to retry the transaction
from the beginning and make sure all the locks are in place.

You can double-check that you have a lock on an object by calling
its confirm_locked! method. This raises a BetterLocking::LockNotHeld
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


Copyright (c) 2010 [Envato](http://envato.com).
Initially developed by [Pete Yandell](http://notahat.com).
Released under an MIT license.
