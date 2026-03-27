module tests.service_test;

import core.domain.entities.user : User;
import core.ports.driven.user_repository : UserRepository;
import core.ports.driving.user_service : UserService;
import core.services.user_service_impl : UserServiceImpl;

/// In-memory fake driven adapter for testing without MongoDB.
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

// ── Unit tests — test the core via the driving port ─────

unittest
{
    auto repo    = new InMemoryUserRepository();
    UserService svc = new UserServiceImpl(repo);

    // createUser
    auto user = svc.createUser("Alice", "alice@example.com");
    assert(user.name == "Alice");
    assert(user.email == "alice@example.com");
    assert(user.id.length > 0);

    // getUser
    auto found = svc.getUser(user.id);
    assert(found !is null);
    assert(found.name == "Alice");

    // listUsers
    svc.createUser("Bob", "bob@example.com");
    assert(svc.listUsers().length == 2);

    // updateUser
    assert(svc.updateUser(user.id, "Alice Updated", ""));
    auto updated = svc.getUser(user.id);
    assert(updated.name == "Alice Updated");
    assert(updated.email == "alice@example.com"); // unchanged

    // deleteUser
    assert(svc.deleteUser(user.id));
    assert(svc.getUser(user.id) is null);

    // delete non-existent returns false
    assert(!svc.deleteUser("nonexistent-id"));
}
