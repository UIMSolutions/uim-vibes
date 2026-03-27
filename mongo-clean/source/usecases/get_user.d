module usecases.get_user;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

/// Use-case: Retrieve a single user by ID.
class GetUserUseCase
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    User* execute(string id)
    {
        return repo.findById(id);
    }
}
