module app;

import vibe.d;
import vibe.db.redis.redis : RedisClient;

import infrastructure.redis_user_repository : RedisUserRepository;
import usecases.create_user : CreateUserUseCase;
import usecases.get_user : GetUserUseCase;
import usecases.list_users : ListUsersUseCase;
import usecases.update_user : UpdateUserUseCase;
import usecases.delete_user : DeleteUserUseCase;
import presentation.user_controller : UserController;

/// Composition root — wires all layers together.
/// Dependencies flow inward:
///   presentation → usecases → domain ← infrastructure
version(unittest) {} else
shared static this()
{
    // ── Infrastructure ───────────────────────────────────
    auto redisClient = new RedisClient("127.0.0.1", 6379);
    auto db       = redisClient.getDatabase(0);
    auto userRepo = new RedisUserRepository(db);

    // ── Use cases ────────────────────────────────────────
    auto createUC = new CreateUserUseCase(userRepo);
    auto getUC    = new GetUserUseCase(userRepo);
    auto listUC   = new ListUsersUseCase(userRepo);
    auto updateUC = new UpdateUserUseCase(userRepo);
    auto deleteUC = new DeleteUserUseCase(userRepo);

    // ── Presentation ─────────────────────────────────────
    auto controller = new UserController(createUC, getUC, listUC, updateUC, deleteUC);

    auto router = new URLRouter;
    controller.register(router);

    // ── HTTP Server ──────────────────────────────────────
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);
    logInfo("Clean Architecture (Redis) server listening on http://0.0.0.0:8080");
}
