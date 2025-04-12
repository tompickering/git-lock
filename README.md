# git-lock

Git extension to support file locking.

Locks are not enforcing. This simply offers developers a way to register that they are working with particular files which they would prefer were left unchanged by others until their work is complete. This will be made visible to other developers when they attempt to acquire a lock on the same file. This is helpful when working on binary assets, non-mergeable files or when making complex or significant code changes.

# Installation

Make `git-lock` available somewhere in your client's `$PATH`.

Nothing is required server-side.

# Usage

Attempt to acquire a lock:

```bash
git lock acquire path/to/file
```

Release a lock:

```bash
git lock release path/to/file
```

Locks are synced to the remote specified with `git config lock.remote` - defaulting to `origin` if this is unspecified.

## How does it work?

The first time a `git-lock` command is run by a client, a new orphan commit is created and pushed to a branch with name `git-lock`. Any time a client runs a `git-lock` command, their local `git-lock` branch will be synced with the remote.

When a lock is acquired, a file is created in this branch at the same location as the target file. This will contain the name of the user who locked the file.

All information is tracked using standard git facilities, and all updates are driven by clients. As such, nothing special is required on the remote, and this can be used with any git server.
