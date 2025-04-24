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

To view a list of all locks currently held by anyone:

```bash
git lock show
```

To check if a particular file is held by anyone:

```bash
git lock check path/to/file
```

To check all your modified and staged files for locks held by anyone else:

```bash
git lock check
```

## Pre-Commit Hook

A pre-commit hook is installed the first time a `git lock` command is run. This will check if any of the staged files are locked by another user. If so - or if the latest lock data cannot be fetched from the remote - the commit is aborted.

To disable this enforcement, set `git config lock.noblockcommit 1`. In this case, the commit will be allowed if lock information cannot be synced. If a lock breach is detected, a report will be displayed for several seconds before the commit process continues.

## Pre-Push Hook

A pre-push hook is installed the first time a `git lock` command is run. If the branch to be pushed has an upstream branch on the remote, the delta between this and the local branch will be checked for any modified files which have been locked by another user. If so, the push is aborted.

To disable this enforcement, set `git config lock.noblockpush 1`. In this case, if a lock breach is detected, a report will be displayed for several seconds before the push continues.

## How does it work?

The first time a `git-lock` command is run by a client, a new orphan commit is created and pushed to a branch with name `git-lock`. Any time a client runs a `git-lock` command, their local `git-lock` branch will be synced with the remote.

When a lock is acquired, a file is created in this branch at the same location as the target file. This will contain the name of the user who locked the file.

All information is tracked using standard git facilities, and all updates are driven by clients. As such, nothing special is required on the remote, and this can be used with any git server.
