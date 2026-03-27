# Clean Architecture — D, vibe.d & MongoDB

A minimal example of **Clean Architecture** (Ports & Adapters) in D with vibe.d for HTTP and MongoDB for persistence.

## Architecture

```
┌──────────────────────────────────────────────────────┐
│  Presentation (vibe.d controllers)                   │
│    source/presentation/user_controller.d             │
├──────────────────────────────────────────────────────┤
│  Use Cases (application business rules)              │
│    source/usecases/{create,get,list,update,delete}_  │
├──────────────────────────────────────────────────────┤
│  Domain (entities + repository interfaces)           │
│    source/domain/entities/user.d                     │
│    source/domain/repositories/user_repository.d      │
├──────────────────────────────────────────────────────┤
│  Infrastructure (MongoDB adapter)                    │
│    source/infrastructure/mongo_user_repository.d     │
└──────────────────────────────────────────────────────┘
```

**Dependency rule:** outer layers depend on inner layers, never the reverse.

- `domain/` — pure D structs & interfaces; zero framework imports
- `usecases/` — orchestration logic; depends only on `domain`
- `infrastructure/` — implements `domain` interfaces with MongoDB
- `presentation/` — maps HTTP ↔ use-case calls
- `app.d` — composition root that wires everything together

## Prerequisites

- **D compiler** (dmd / ldc2)
- **dub** (D package manager)
- **MongoDB** running on `localhost:27017`

## Build & Run

```bash
dub build            # compile
dub run              # start server on :8080
dub test             # run unit tests (no MongoDB needed)
```

## API

| Method | Endpoint            | Body (JSON)                  | Description    |
|--------|---------------------|------------------------------|----------------|
| GET    | `/api/users`        | —                            | List all users |
| GET    | `/api/users/{id}`   | —                            | Get user by ID |
| POST   | `/api/users`        | `{"name":"…","email":"…"}`   | Create user    |
| PUT    | `/api/users/{id}`   | `{"name":"…","email":"…"}`   | Update user    |
| DELETE | `/api/users/{id}`   | —                            | Delete user    |

### Quick test with curl

```bash
# Create
curl -X POST http://localhost:8080/api/users \
  -H 'Content-Type: application/json' \
  -d '{"name":"Alice","email":"alice@example.com"}'

# List
curl http://localhost:8080/api/users

# Get (replace <id>)
curl http://localhost:8080/api/users/<id>

# Update
curl -X PUT http://localhost:8080/api/users/<id> \
  -H 'Content-Type: application/json' \
  -d '{"name":"Alice Updated"}'

# Delete
curl -X DELETE http://localhost:8080/api/users/<id>
```
