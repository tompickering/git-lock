Feature: File locking

    Scenario: Acquire a lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0 with message Add a.txt
        When we lock LOCAL0 a.txt
        Then LOCAL0 a.txt is locked by User0 <user0@git.lock>
        And LOCAL0 a.txt check succeeds

    Scenario: Acquire and release a lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0 with message Add a.txt
        When we lock LOCAL0 a.txt
        And we release LOCAL0 a.txt
        Then LOCAL0 a.txt is not locked
        And LOCAL0 a.txt check succeeds

    Scenario: A user checks another user's lock
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0 with message Add a.txt
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL1 has initialised git-lock
        When we lock LOCAL0 a.txt
        Then LOCAL1 a.txt is locked by User0 <user0@git.lock>
        And LOCAL1 a.txt check fails

    Scenario: A user checks another user's lock (reverse)
        Given a git repo REPO
        And we have cloned REPO to LOCAL0
        And LOCAL0 is configured with user.name User0
        And LOCAL0 is configured with user.email user0@git.lock
        And we create file a.txt in LOCAL0
        And we add file a.txt in LOCAL0
        And we commit LOCAL0 with message Add a.txt
        And we push LOCAL0
        And we have cloned REPO to LOCAL1
        And LOCAL1 is configured with user.name User1
        And LOCAL1 is configured with user.email user1@git.lock
        And LOCAL0 has initialised git-lock
        When we lock LOCAL1 a.txt
        Then LOCAL0 a.txt is locked by User1 <user1@git.lock>
        And LOCAL0 a.txt check fails
