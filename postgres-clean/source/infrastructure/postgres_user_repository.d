module infrastructure.postgres_user_repository;

import std.conv : to;
import std.datetime : SysTime;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

import vibe.db.postgresql;

/// Adapter — PostgreSQL implementation of the UserRepository port.
/// This is the only module that knows about PostgreSQL.
class PostgresUserRepository : UserRepository
{
    private PostgresClient pool;

    this(PostgresClient pool)
    {
        this.pool = pool;
        ensureTable();
    }

    User[] findAll()
    {
        User[] users;
        auto result = query("SELECT id, name, email, created_at, updated_at FROM users ORDER BY created_at");
        foreach (row; result)
        {
            users ~= rowToUser(row);
        }
        return users;
    }

    User* findById(string id)
    {
        auto result = query(
            "SELECT id, name, email, created_at, updated_at FROM users WHERE id = $1",
            id
        );
        if (result.length == 0)
            return null;
        auto u = new User();
        *u = rowToUser(result[0]);
        return u;
    }

    void save(User user)
    {
        query(
            "INSERT INTO users (id, name, email, created_at, updated_at) VALUES ($1, $2, $3, $4, $5)",
            user.id, user.name, user.email,
            user.createdAt.toISOExtString(), user.updatedAt.toISOExtString()
        );
    }

    void update(User user)
    {
        query(
            "UPDATE users SET name = $1, email = $2, updated_at = $3 WHERE id = $4",
            user.name, user.email, user.updatedAt.toISOExtString(), user.id
        );
    }

    void remove(string id)
    {
        query("DELETE FROM users WHERE id = $1", id);
    }

    // ── Helpers ──────────────────────────────────────────

    private auto query(T...)(string sql, T params)
    {
        return pool.pickConnection(
            (scope conn)
            {
                static if (T.length == 0)
                    return conn.exec(sql);
                else
                    return conn.execParams(sql, params);
            }
        );
    }

    private void ensureTable()
    {
        query(
            "CREATE TABLE IF NOT EXISTS users ("
            ~ "id TEXT PRIMARY KEY, "
            ~ "name TEXT NOT NULL, "
            ~ "email TEXT NOT NULL, "
            ~ "created_at TEXT NOT NULL, "
            ~ "updated_at TEXT NOT NULL"
            ~ ")"
        );
    }

    private static User rowToUser(R)(R row)
    {
        return User(
            row["id"].as!string,
            row["name"].as!string,
            row["email"].as!string,
            SysTime.fromISOExtString(row["created_at"].as!string),
            SysTime.fromISOExtString(row["updated_at"].as!string),
        );
    }
}
