Feature: File locking

    Scenario: Acquire a lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        When we lock LOCAL0 a.txt
        Then LOCAL0 a.txt is locked by User0 <user0@git.lock>
        And LOCAL0 a.txt check succeeds
        And LOCAL0 git-lock show contains ./a.txt	User0 <user0@git.lock>
        And LOCAL0 cannot lock a.txt

    Scenario: Acquire and release a lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        When we lock LOCAL0 a.txt
        And we release LOCAL0 a.txt
        Then LOCAL0 a.txt is not locked
        And LOCAL0 a.txt check succeeds
        And LOCAL0 git-lock show does not contain ./a.txt	User0 <user0@git.lock>
        And LOCAL0 cannot release a.txt
        And LOCAL0 can lock a.txt
        And LOCAL0 can release a.txt

    Scenario: A user checks another user's lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 has initialised git-lock
        When we lock LOCAL0 a.txt
        Then LOCAL1 a.txt is locked by User0 <user0@git.lock>
        And LOCAL1 a.txt check fails
        And LOCAL1 cannot lock a.txt
        And LOCAL0 git-lock show contains ./a.txt	User0 <user0@git.lock>
        And LOCAL1 git-lock show contains ./a.txt	User0 <user0@git.lock>

    Scenario: A user checks another user's lock (reverse)
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we push LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL0 has initialised git-lock
        When we lock LOCAL1 a.txt
        Then LOCAL0 a.txt is locked by User1 <user1@git.lock>
        And LOCAL0 a.txt check fails
        And LOCAL0 cannot lock a.txt
        And LOCAL0 git-lock show contains ./a.txt	User1 <user1@git.lock>
        And LOCAL1 git-lock show contains ./a.txt	User1 <user1@git.lock>

    Scenario: A user attempts to commit a file locked by another user
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 has initialised git-lock
        When we lock LOCAL0 a.txt
        And we modify file a.txt in LOCAL1
        And we add file a.txt in LOCAL1
        Then LOCAL1 commit fails

    Scenario: A user attempts to commit a file locked by another user (nonblocking)
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 is configured with lock.noblockcommit 1
        And LOCAL1 has initialised git-lock
        When we lock LOCAL0 a.txt
        And we modify file a.txt in LOCAL1
        And we add file a.txt in LOCAL1
        Then LOCAL1 commit delays

    Scenario: A user attempts to push a file locked by another user
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 has initialised git-lock
        When we modify file a.txt in LOCAL1
        And we add file a.txt in LOCAL1
        And we commit LOCAL1
        And we lock LOCAL0 a.txt
        Then LOCAL1 push fails

    Scenario: A user attempts to push a file locked by another user (nonblocking)
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 is configured with lock.noblockpush 1
        And LOCAL1 has initialised git-lock
        When we modify file a.txt in LOCAL1
        And we add file a.txt in LOCAL1
        And we commit LOCAL1
        And we lock LOCAL0 a.txt
        Then LOCAL1 push delays
