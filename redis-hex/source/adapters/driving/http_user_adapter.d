module adapters.driving.http_user_adapter;

import std.conv : to;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.data.json : Json;
import vibe.http.status : HTTPStatus;

import core.domain.entities.user : User;
import core.ports.driving.user_service : UserService;

/// Driving adapter — translates HTTP requests into calls on the
/// driving port (UserService). Knows nothing about persistence.
class HttpUserAdapter
{
    private UserService service;

    this(UserService service)
    {
        this.service = service;
    }

    /// Register all routes on the given router.
    void register(URLRouter router)
    {
        router.get("/api/users", &handleList);
        router.get("/api/users/*", &handleGet);
        router.post("/api/users", &handleCreate);
        router.put("/api/users/*", &handleUpdate);
        router.delete_("/api/users/*", &handleDelete);
    }

    // ── Handlers ─────────────────────────────────────────

    private void handleList(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto users = service.listUsers();
        auto arr = Json.emptyArray;
        foreach (u; users)
            arr ~= userToJson(u);
        res.writeJsonBody(arr);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto id = extractId(req);
        auto userPtr = service.getUser(id);
        if (userPtr is null)
        {
            res.writeJsonBody(Json(["error": Json("User not found")]), HTTPStatus.notFound);
            return;
        }
        res.writeJsonBody(userToJson(*userPtr));
    }

    private void handleCreate(HTTPServerRequest req, HTTPServerResponse res)
    {
        try
        {
            auto json  = req.json;
            auto name  = json["name"].get!string;
            auto email = json["email"].get!string;
            auto user  = service.createUser(name, email);
            res.writeJsonBody(userToJson(user), HTTPStatus.created);
        }
        catch (Exception e)
        {
            res.writeJsonBody(Json(["error": Json("Invalid request body")]), HTTPStatus.badRequest);
        }
    }

    private void handleUpdate(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto id = extractId(req);
        try
        {
            auto json    = req.json;
            string name  = json["name"].opt!string("");
            string email = json["email"].opt!string("");
            if (service.updateUser(id, name, email))
                res.writeJsonBody(Json(["status": Json("updated")]));
            else
                res.writeJsonBody(Json(["error": Json("User not found")]), HTTPStatus.notFound);
        }
        catch (Exception e)
        {
            res.writeJsonBody(Json(["error": Json("Invalid request body")]), HTTPStatus.badRequest);
        }
    }

    private void handleDelete(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto id = extractId(req);
        if (service.deleteUser(id))
            res.writeJsonBody(Json(["status": Json("deleted")]));
        else
            res.writeJsonBody(Json(["error": Json("User not found")]), HTTPStatus.notFound);
    }

    // ── Helpers ──────────────────────────────────────────

    private static string extractId(HTTPServerRequest req)
    {
        import std.string : split;
        auto parts = req.requestURI.split("/");
        return parts.length >= 4 ? parts[3] : "";
    }

    private static Json userToJson(User u)
    {
        auto j = Json.emptyObject;
        j["id"]        = Json(u.id);
        j["name"]      = Json(u.name);
        j["email"]     = Json(u.email);
        j["createdAt"] = Json(u.createdAt.toISOExtString());
        j["updatedAt"] = Json(u.updatedAt.toISOExtString());
        return j;
    }
}
