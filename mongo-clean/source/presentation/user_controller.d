module presentation.user_controller;

import std.conv : to;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.data.json : Json, parseJsonString;
import vibe.http.status : HTTPStatus;

import domain.entities.user : User;
import usecases.create_user : CreateUserUseCase;
import usecases.get_user : GetUserUseCase;
import usecases.list_users : ListUsersUseCase;
import usecases.update_user : UpdateUserUseCase;
import usecases.delete_user : DeleteUserUseCase;

/// Presentation layer — thin HTTP adapter that delegates to use cases.
class UserController
{
    private CreateUserUseCase createUC;
    private GetUserUseCase getUC;
    private ListUsersUseCase listUC;
    private UpdateUserUseCase updateUC;
    private DeleteUserUseCase deleteUC;

    this(
        CreateUserUseCase createUC,
        GetUserUseCase getUC,
        ListUsersUseCase listUC,
        UpdateUserUseCase updateUC,
        DeleteUserUseCase deleteUC,
    )
    {
        this.createUC = createUC;
        this.getUC    = getUC;
        this.listUC   = listUC;
        this.updateUC = updateUC;
        this.deleteUC = deleteUC;
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
        auto users = listUC.execute();
        auto arr = Json.emptyArray;
        foreach (u; users)
            arr ~= userToJson(u);
        res.writeJsonBody(arr);
    }

    private void handleGet(HTTPServerRequest req, HTTPServerResponse res)
    {
        auto id = extractId(req);
        auto userPtr = getUC.execute(id);
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
            auto json = req.json;
            auto name  = json["name"].get!string;
            auto email = json["email"].get!string;
            auto user = createUC.execute(name, email);
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
            auto json  = req.json;
            string name  = json["name"].opt!string("");
            string email = json["email"].opt!string("");
            if (updateUC.execute(id, name, email))
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
        if (deleteUC.execute(id))
            res.writeJsonBody(Json(["status": Json("deleted")]));
        else
            res.writeJsonBody(Json(["error": Json("User not found")]), HTTPStatus.notFound);
    }

    // ── Helpers ──────────────────────────────────────────

    private static string extractId(HTTPServerRequest req)
    {
        import std.string : split;
        auto parts = req.requestURI.split("/");
        // URI: /api/users/<id>  →  parts = ["", "api", "users", "<id>"]
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
