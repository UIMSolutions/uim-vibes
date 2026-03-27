module usecases.create_user;

import std.datetime : Clock;
import std.conv : to;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

/// Use-case: Create a new user.
/// Depends only on the domain layer (entity + repository interface).
class CreateUserUseCase
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    /// Execute the use case and return the created user.
    User execute(string name, string email)
    {
        import std.uuid : randomUUID;

        auto now = Clock.currTime();
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
}
