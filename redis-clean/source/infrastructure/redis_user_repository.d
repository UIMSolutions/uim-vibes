module infrastructure.redis_user_repository;

import std.conv : to;
import std.datetime : SysTime;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

import vibe.db.redis.redis : RedisDatabase;

/// Adapter — Redis implementation of the UserRepository port.
/// This is the only module that knows about Redis.
///
/// Storage layout:
///   - Hash  "user:{id}" → fields: name, email, createdAt, updatedAt
///   - Set   "user:ids"  → all user IDs (for listing)
class RedisUserRepository : UserRepository
{
    private RedisDatabase db;

    this(RedisDatabase db)
    {
        this.db = db;
    }

    User[] findAll()
    {
        User[] users;
        auto ids = db.smembers("user:ids");
        foreach (id; ids)
        {
            auto userPtr = findById(id);
            if (userPtr !is null)
                users ~= *userPtr;
        }
        return users;
    }

    User* findById(string id)
    {
        auto key = userKey(id);
        if (!db.exists(key))
            return null;

        auto reply = db.hmget(key, "name", "email", "createdAt", "updatedAt");

        string[4] fields;
        size_t i;
        foreach (val; reply)
        {
            if (i < 4)
                fields[i++] = val;
        }

        if (i < 4)
            return null;

        auto u = new User();
        *u = User(
            id,
            fields[0],
            fields[1],
            SysTime.fromISOExtString(fields[2]),
            SysTime.fromISOExtString(fields[3]),
        );
        return u;
    }

    void save(User user)
    {
        auto key = userKey(user.id);
        db.hmset(
            key,
            "name", user.name,
            "email", user.email,
            "createdAt", user.createdAt.toISOExtString(),
            "updatedAt", user.updatedAt.toISOExtString(),
        );
        db.sadd("user:ids", user.id);
    }

    void update(User user)
    {
        auto key = userKey(user.id);
        db.hmset(
            key,
            "name", user.name,
            "email", user.email,
            "updatedAt", user.updatedAt.toISOExtString(),
        );
    }

    void remove(string id)
    {
        db.del(userKey(id));
        db.srem("user:ids", id);
    }

    // ── Helpers ──────────────────────────────────────────

    private static string userKey(string id)
    {
        return "user:" ~ id;
    }
}
