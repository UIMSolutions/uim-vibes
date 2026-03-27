module tests.usecases_test;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;
import usecases.create_user : CreateUserUseCase;
import usecases.get_user : GetUserUseCase;
import usecases.list_users : ListUsersUseCase;
import usecases.update_user : UpdateUserUseCase;
import usecases.delete_user : DeleteUserUseCase;

/// In-memory fake repository for testing use cases without PostgreSQL.
class InMemoryUserRepository : UserRepository
{
    private User[string] store;

    User[] findAll()
    {
        return store.values;
    }

    User* findById(string id)
    {
        if (auto p = id in store)
            return p;
        return null;
    }

    void save(User user)
    {
        store[user.id] = user;
    }

    void update(User user)
    {
        store[user.id] = user;
    }

    void remove(string id)
    {
        store.remove(id);
    }
}

// ── Unit tests ──────────────────────────────────────────

unittest
{
    auto repo = new InMemoryUserRepository();

    // CreateUserUseCase
    auto createUC = new CreateUserUseCase(repo);
    auto user = createUC.execute("Alice", "alice@example.com");
    assert(user.name == "Alice");
    assert(user.email == "alice@example.com");
    assert(user.id.length > 0);

    // GetUserUseCase
    auto getUC = new GetUserUseCase(repo);
    auto found = getUC.execute(user.id);
    assert(found !is null);
    assert(found.name == "Alice");

    // ListUsersUseCase
    auto listUC = new ListUsersUseCase(repo);
    createUC.execute("Bob", "bob@example.com");
    assert(listUC.execute().length == 2);

    // UpdateUserUseCase
    auto updateUC = new UpdateUserUseCase(repo);
    assert(updateUC.execute(user.id, "Alice Updated", ""));
    auto updated = getUC.execute(user.id);
    assert(updated.name == "Alice Updated");
    assert(updated.email == "alice@example.com"); // unchanged

    // DeleteUserUseCase
    auto deleteUC = new DeleteUserUseCase(repo);
    assert(deleteUC.execute(user.id));
    assert(getUC.execute(user.id) is null);

    // Delete non-existent returns false
    assert(!deleteUC.execute("nonexistent-id"));
}
