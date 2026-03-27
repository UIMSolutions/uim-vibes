module usecases.list_users;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

/// Use-case: List all users.
class ListUsersUseCase
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    User[] execute()
    {
        return repo.findAll();
    }
}
