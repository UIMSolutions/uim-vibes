module core.ports.driven.user_repository;

import core.domain.entities.user : User;

/// Driven port (outbound) — defines how the application persists users.
/// Implemented by infrastructure adapters (e.g. Redis, in-memory).
interface UserRepository
{
    User[] findAll();
    User* findById(string id);
    void save(User user);
    void update(User user);
    void remove(string id);
}
