module app;

import vibe.d;
import vibe.db.postgresql;

import infrastructure.postgres_user_repository : PostgresUserRepository;
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
    void initConn(Connection conn)
    {
        conn.exec("SET client_encoding TO 'UTF8'");
    }

    auto pgPool  = new PostgresClient("host=127.0.0.1 port=5432 dbname=clean_arch_demo user=postgres password=Postgres.For.Ever", 4, &initConn);
    auto userRepo = new PostgresUserRepository(pgPool);

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
    logInfo("Clean Architecture (PostgreSQL) server listening on http://0.0.0.0:8080");
}
