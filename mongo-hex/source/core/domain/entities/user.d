module core.domain.entities.user;

import std.datetime : SysTime;

/// Domain entity — pure data, no framework dependencies.
struct User
{
    string id;
    string name;
    string email;
    SysTime createdAt;
    SysTime updatedAt;
}
