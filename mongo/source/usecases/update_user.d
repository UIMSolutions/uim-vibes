module usecases.update_user;

import std.datetime : Clock;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

/// Use-case: Update an existing user's name and/or email.
class UpdateUserUseCase
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    bool execute(string id, string name, string email)
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
}
