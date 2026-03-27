module app;

import vibe.d;
import vibe.db.redis.redis : RedisClient;

import adapters.driven.redis_user_repository : RedisUserRepository;
import core.services.user_service_impl : UserServiceImpl;
import adapters.driving.http_user_adapter : HttpUserAdapter;

/// Composition root — wires adapters to ports.
///
///   ┌─────────────────────────────────────────────────┐
///   │  Driving Adapter        Core        Driven Adapter │
///   │  (HTTP/vibe.d) ──▶ [UserService] ──▶ (Redis)      │
///   └─────────────────────────────────────────────────┘
version(unittest) {} else
shared static this()
{
    // ── Driven adapter (outbound) ────────────────────────
    auto redisClient = new RedisClient("127.0.0.1", 6379);
    auto db          = redisClient.getDatabase(0);
    auto userRepo    = new RedisUserRepository(db);

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
    logInfo("Hexagonal Architecture (Redis) server listening on http://0.0.0.0:8080");
}
