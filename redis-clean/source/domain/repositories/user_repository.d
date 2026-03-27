module domain.repositories.user_repository;

import domain.entities.user : User;

/// Port — abstract repository interface.
/// The domain layer defines *what* persistence looks like,
/// but never *how* it is implemented.
interface UserRepository
{
    User[] findAll();
    User* findById(string id);
    void save(User user);
    void update(User user);
    void remove(string id);
}
