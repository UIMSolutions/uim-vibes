module core.ports.driving.user_service;

import core.domain.entities.user : User;

/// Driving port (inbound) — defines the operations the outside world
/// can invoke on the application core.
/// Implemented by application services.
interface UserService
{
    User[] listUsers();
    User* getUser(string id);
    User createUser(string name, string email);
    bool updateUser(string id, string name, string email);
    bool deleteUser(string id);
}
