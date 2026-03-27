module infrastructure.mongo_user_repository;

import std.conv : to;
import std.datetime : SysTime, Clock;

import domain.entities.user : User;
import domain.repositories.user_repository : UserRepository;

import vibe.db.mongo.mongo;
import vibe.data.bson : Bson;

/// Adapter — MongoDB implementation of the UserRepository port.
/// This is the only module that knows about MongoDB.
class MongoUserRepository : UserRepository
{
    private MongoCollection collection;

    this(MongoClient client, string dbName)
    {
        this.collection = client.getCollection(dbName ~ ".users");
    }

    User[] findAll()
    {
        User[] users;
        foreach (doc; collection.find())
        {
            users ~= fromBson(doc);
        }
        return users;
    }

    User* findById(string id)
    {
        auto result = collection.findOne(["_id": id]);
        if (result == Bson(null))
            return null;
        auto u = new User();
        *u = fromBson(result);
        return u;
    }

    void save(User user)
    {
        collection.insertOne(toBson(user));
    }

    void update(User user)
    {
        collection.replaceOne(["_id": user.id], toBson(user));
    }

    void remove(string id)
    {
        collection.deleteOne(["_id": id]);
    }

    // ── BSON mapping helpers ──────────────────────────────

    private static Bson toBson(User u)
    {
        auto doc = Bson.emptyObject;
        doc["_id"]       = Bson(u.id);
        doc["name"]      = Bson(u.name);
        doc["email"]     = Bson(u.email);
        doc["createdAt"] = Bson(u.createdAt.toISOExtString());
        doc["updatedAt"] = Bson(u.updatedAt.toISOExtString());
        return doc;
    }

    private static User fromBson(Bson doc)
    {
        return User(
            doc["_id"].get!string,
            doc["name"].get!string,
            doc["email"].get!string,
            SysTime.fromISOExtString(doc["createdAt"].get!string),
            SysTime.fromISOExtString(doc["updatedAt"].get!string),
        );
    }
}
