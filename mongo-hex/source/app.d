module app;

import vibe.d;

import adapters.driven.mongo_user_repository : MongoUserRepository;
import core.services.user_service_impl : UserServiceImpl;
import adapters.driving.http_user_adapter : HttpUserAdapter;

/// Composition root — wires adapters to ports.
///
///   ┌─────────────────────────────────────────────────┐
///   │  Driving Adapter        Core        Driven Adapter │
///   │  (HTTP/vibe.d) ──▶ [UserService] ──▶ (MongoDB)    │
///   └─────────────────────────────────────────────────┘
version(unittest) {} else
shared static this()
{
    // ── Driven adapter (outbound) ────────────────────────
    auto mongoClient = connectMongoDB("mongodb://127.0.0.1:27017");
    auto userRepo    = new MongoUserRepository(mongoClient, "hex_arch_demo");

    // ── Application core ─────────────────────────────────
    auto userService = new UserServiceImpl(userRepo);

    // ── Driving adapter (inbound) ────────────────────────
    auto httpAdapter = new HttpUserAdapter(userService);

    auto router = new URLRouter;
    httpAdapter.register(router);

    // ── HTTP Server ──────────────────────────────────────
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["0.0.0.0"];

    listenHTTP(settings, router);
    logInfo("Hexagonal Architecture (MongoDB) server listening on http://0.0.0.0:8080");
}
