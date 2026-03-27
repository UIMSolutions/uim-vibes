module usecases.delete_user;

import domain.repositories.user_repository : UserRepository;

/// Use-case: Delete a user by ID.
class DeleteUserUseCase
{
    private UserRepository repo;

    this(UserRepository repo)
    {
        this.repo = repo;
    }

    bool execute(string id)
    {
        auto userPtr = repo.findById(id);
        if (userPtr is null)
            return false;
        repo.remove(id);
        return true;
    }
}
