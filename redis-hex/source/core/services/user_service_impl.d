module core.services.user_service_impl;

import std.conv : to;
import std.datetime : Clock;

import core.domain.entities.user : User;
import core.ports.driving.user_service : UserService;
import core.ports.driven.user_repository : UserRepository;

/// Application service — implements the driving port by orchestrating
/// domain logic and delegating persistence to the driven port.
class UserServiceImpl : UserService
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    User[] listUsers()
    {
        return repo.findAll();
    }

    User* getUser(string id)
    {
        return repo.findById(id);
    }

    User createUser(string name, string email)
    {
        import std.uuid : randomUUID;

        auto now  = Clock.currTime();
        auto user = User(
            randomUUID().to!string,
            name,
            email,
            now,
            now,
        );
        repo.save(user);
        return user;
    }

    bool updateUser(string id, string name, string email)
    {
        auto userPtr = repo.findById(id);
        if (userPtr is null)
            return false;

        auto user = *userPtr;
        if (name.length > 0)
            user.name = name;
        if (email.length > 0)
            user.email = email;
        user.updatedAt = Clock.currTime();
        repo.update(user);
        return true;
    }

    bool deleteUser(string id)
    {
        auto userPtr = repo.findById(id);
        if (userPtr is null)
            return false;
        repo.remove(id);
        return true;
    }
}
