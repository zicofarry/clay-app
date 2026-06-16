# Clay Platform — Comprehensive Documentation

> Super-app platform microservices (Gojek-style) berbasis Go + Android Kotlin.
> Mono repo dengan 24 microservices backend, 1 Android frontend, Kafka event-driven architecture, dan Kubernetes deployment.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Monorepo Structure](#2-monorepo-structure)
3. [Technology Stack](#3-technology-stack)
4. [Backend Architecture](#4-backend-architecture)
   - 4.1 API Gateway
   - 4.2 Core Domain Services
   - 4.3 Order Services
   - 4.4 Communication Services
   - 4.5 Search & Geo Services
   - 4.6 Matching & Payment Services
   - 4.7 Merchant & Promotion Services
   - 4.8 Wallet & History Services
   - 4.9 Security & Audit Services
   - 4.10 Shared Library (`clay-shared`)
5. [Frontend Architecture (Android)](#5-frontend-architecture-android)
6. [Communication & Data Flow](#6-communication--data-flow)
   - 6.1 Synchronous (HTTP)
   - 6.2 Asynchronous (Kafka)
7. [Infrastructure](#7-infrastructure)
   - 7.1 Docker Compose
   - 7.2 Kubernetes
   - 7.3 Port Mapping
8. [CI/CD Pipeline](#8-cicd-pipeline)
9. [Data Warehouse Design](#9-data-warehouse-design)
10. [Development Setup](#10-development-setup)

---

## 1. Project Overview

Clay adalah super-app platform yang menyediakan layanan:
- **Ride Hailing** (GoRide/GoCar analog)
- **Food Delivery** (GoFood analog)
- **Package Delivery** (GoSend analog)
- **Digital Wallet** (GoPay analog)
- **Chat** (real-time messaging)
- **Layanan tambahan**: Pet, Waste management, Healthcare, Travel, Bills, Entertainment

### Arsitektur Tingkat Tinggi

```
[Android App] ──HTTP──> [API Gateway :8080] ──> [24 Microservices]
                              │                        │
                              │                   [PostgreSQL/Redis/MongoDB]
                              │                        │
                         [Kafka Events] ──────> [Async Consumers]
```

---

## 2. Monorepo Structure

```
clay-app/
├── backend/                          # Go workspace (24 services + 1 shared lib)
│   ├── go.work                       # Go 1.25 workspace
│   ├── services/                     # 24 microservices
│   │   ├── gateway/                  # API Gateway (reverse proxy)
│   │   ├── auth-service/             # Authentication & Authorization
│   │   ├── user-service/             # User & Driver profiles
│   │   ├── payment-service/          # Payment processing, COD
│   │   ├── food-order-service/       # Food ordering lifecycle
│   │   ├── delivery-order-service/   # Package delivery orders
│   │   ├── ride-order-service/       # Ride hailing orders
│   │   ├── chat-service/             # Real-time messaging
│   │   ├── notification-service/     # Push notification management
│   │   ├── push-service/             # FCM/APNs delivery
│   │   ├── sms-service/              # SMS gateway & OTP
│   │   ├── email-service/            # Email sending & templates
│   │   ├── search-service/           # Elasticsearch full-text search
│   │   ├── geo-service/              # Maps, geocoding, proximity
│   │   ├── matching-service/         # Driver dispatch & matching
│   │   ├── merchant-service/         # Merchant & menu management
│   │   ├── rating-service/           # Ratings & reviews
│   │   ├── promotion-service/        # Promo codes & vouchers
│   │   ├── pricing-service/          # Fare estimation & surge
│   │   ├── wallet-service/           # Digital wallet
│   │   ├── history-service/          # Order history & activity feed
│   │   ├── tracking-service/         # Real-time order tracking
│   │   ├── audit-log-service/        # Immutable audit logs
│   │   └── security-service/         # Fraud detection & IP blacklist
│   ├── pkg/                          # Shared library (clay-shared)
│   └── infra/                        # Docker Compose, K8s manifests
├── frontend/                         # Android app (Kotlin + Jetpack Compose)
│   ├── app/                          # Main app module
│   ├── core/                         # Core modules (common, model, network, data, ui)
│   └── feature/                      # Feature modules (11 feature modules)
├── proto/                            # Protobuf definitions (empty - placeholder)
├── docs/                             # Documentation
├── dummy/                            # Design documents, ERD, Postman collection
├── Jenkinsfile                       # Single CI/CD pipeline
└── README.md
```

---

## 3. Technology Stack

### Backend
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Go | 1.23 - 1.25 | Go workspace multi-module |
| HTTP Framework | stdlib `net/http` | Go 1.22+ routing patterns, no external framework |
| PostgreSQL | 15/16 Alpine | 17 services |
| MongoDB | 6/7 | 5 services |
| Redis | 7 Alpine | 18 services |
| Elasticsearch | 8.13 | Search service |
| Kafka | 7.6 (Confluent) | Event-driven communication |
| Kafka Client | `segmentio/kafka-go` | Used in shared library |
| GORM | `gorm.io/gorm` | Rating, Promotion, History services |

### Frontend
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Kotlin | 2.1.0 | Language |
| Jetpack Compose | BOM 2024.12.01 | UI framework |
| Material Design 3 | 1.3.1 | Design system |
| Hilt | 2.53.1 | Dependency injection |
| Retrofit | 2.11 | HTTP client |
| Moshi | 1.15 | JSON serialization |
| Coil | 2.7.0 | Image loading |
| Gradle | 8.9 | Build system |
| minSdk | 26 (Android 8.0) | |
| targetSdk | 35 (Android 15) | |

### Infrastructure & CI/CD
| Teknologi | Keterangan |
|-----------|------------|
| Docker | Multi-stage builds (golang:1.25-alpine → alpine:3.19) |
| Docker Compose | Single 1070-line compose file orchestrating everything |
| Kubernetes | Manifests with Deployments, Services, Secrets |
| Jenkins | Single pipeline, change-based conditional builds |
| Kafka UI | `provectuslabs/kafka-ui` for topic monitoring |
| Adminer | PostgreSQL web admin per service |

---

## 4. Backend Architecture

### 4.1 API Gateway (`gateway`)

**Port:** 8080 (LoadBalancer)
**Role:** Single entry point untuk semua traffic eksternal.

**Fitur:**
- **Routing:** YAML-based route table (1437 lines) mapping paths to upstream services
- **Authentication:** JWT validation dengan role-based authorization
  - Modes: `none`, `required`, `required_roles:[role1,role2]`
  - Inject headers: `X-User-ID`, `X-User-Role`
- **Rate Limiting:** Redis-backed sliding window per user/IP
- **Middleware Stack:** Recovery → RequestID → AccessLog → CORS → (Auth → RateLimit → Proxy)
- **Proxying:** `httputil.ReverseProxy` dengan path stripping & header injection

**Routes example:**
```yaml
- path: /api/v1/auth
  methods: [POST, GET]
  upstream: clay-auth-service:8080
  auth: none
  rate_limit: 20/m
  strip_prefix: /api/v1
```

### 4.2 Core Domain Services

#### Auth Service (`auth-service`)
**Port:** 8001 | **DB:** PostgreSQL (auth_db), Redis (planned)

**Endpoints:** Register, Login (password + OTP), OTP verification, Token refresh, Logout, Session management, Password management

**Kafka Topics (planned):** `auth.user_registered`, `auth.login_success`, `auth.login_failed`

**Architecture:** Handler → Service (interface) → Repository (database/sql) → PostgreSQL

#### User Service (`user-service`)
**Port:** 8002 | **DB:** PostgreSQL + Redis (profile cache)

**Endpoints:**
- User CRUD (`/users/me`)
- Address management (`/addresses`)
- Driver profile registration & documents
- Driver online/offline status
- User settings
- Internal: `POST /internal/users/lookup-by-phone`

### 4.3 Order Services

Tiga service order dengan pola yang mirip: Ride, Food, dan Delivery. Semua mengikuti lifecycle:
```
Estimate → Create → Active → Driver Accept/Reject → In Progress → Complete/Cancel → Rate
```

#### Ride Order Service (`ride-order-service`)
**Port:** 8016 / 3003 | **DB:** PostgreSQL + Redis

#### Food Order Service (`food-order-service`)
**Port:** 8017 | **DB:** PostgreSQL + MongoDB + Redis + Kafka

**Role:** Food order dari estimation sampai delivery + rating.
**Endpoints:** Estimate, Create, Cancel, Merchant confirm/reject, Driver pickup/deliver, Rate

#### Delivery Order Service (`delivery-order-service`)
**Port:** 8018 / 3004 | **DB:** PostgreSQL + Redis

### 4.4 Communication Services

#### Chat Service (`chat-service`)
**Port:** 8008 | **DB:** MongoDB

**Role:** Real-time chat user ↔ driver, user ↔ merchant
**Endpoints:** Rooms, Messages, Read receipts, Unread count
**Note:** Menggunakan polling REST (belum WebSocket)

#### Notification Service (`notification-service`)
**Port:** 8005 | **DB:** PostgreSQL

**Role:** Manajemen notifikasi — device token registration, preferences, notification history, templates
**Endpoints:** Device tokens, Preferences, Notification list, Admin templates, Internal send (single + batch)

#### Push Service (`push-service`)
**Port:** 8014 | **DB:** Redis

**Role:** Deliver push notification ke FCM/APNs. Internal-only API.
**Endpoints:** Send push (single/batch), Topic subscribe/unsubscribe/send
**Note:** FCM/APNs SDK integration masih TODO

#### SMS Service (`sms-service`)
**Port:** 8021 | **DB:** Redis (OTP storage, rate limiting)

**Role:** SMS OTP & generic SMS sending
**Endpoints:** Send OTP, Verify OTP, Send generic SMS, Delivery webhook

#### Email Service (`email-service`)
**Port:** 8003 | **DB:** Redis

**Role:** Email sending with templates
**Endpoints:** Send email, Status check, Delivery webhook, Template CRUD

### 4.5 Search & Geo Services

#### Search Service (`search-service`)
**Port:** 8019 | **DB:** Elasticsearch + Redis (cache)

**Role:** Full-text search untuk merchants, menu items, trending/popular
**Endpoints:** Search merchants/items, Trending, Suggest (autocomplete), Popular, Internal indexing + reindex

#### Geo Service (`geo-service`)
**Port:** 8009 | **DB:** PostgreSQL + Kafka (consumer)

**Role:** Location-based services — maps, routing, geocoding, proximity, geofencing
**Endpoints:**
- Maps: Estimate, polyline, routing, snapping, traffic, geocode, reverse-geocode, places
- Drivers: Location update, nearby drivers
- Internal: Batch driver locations, ETA

**Kafka:** Consumer untuk driver location update events dari Matching Service

### 4.6 Matching & Payment Services

#### Matching Service (`matching-service`)
**Port:** 8010 | **DB:** Redis (driver state, geospatial index)

**Role:** Driver dispatch & matching engine.
**Endpoints:** Go online/offline, Location update, Heartbeat, Dispatch respond, Mode setting, Earnings
**Internal:** Dispatch start/cancel, Nearby drivers, Zone stats, Free driver

**Architecture:** Calls Geo Service via HTTP for nearby driver queries. Redis sebagai primary store untuk driver state dan geospatial indexing.

#### Payment Service (`payment-service`)
**Port:** 8004 | **DB:** PostgreSQL + Redis + Kafka

**Role:** Payment method management, COD verification, transaction processing (charge/refund), hold/capture/release, settlements
**Endpoints:**
- Payment methods CRUD (+ set default)
- COD verification (initiate → OTP → respond)
- Transaction history
- Internal: Charge, Refund, Hold, Capture, Release, Settlement

**Kafka Topics Produced:** `payment.charged`, `payment.failed`, `payment.refunded`, `payment.held`, `payment.captured`, `payment.released`, `settlement.created`

**Redis:** Rate limiting, idempotency key store

### 4.7 Merchant & Promotion Services

#### Merchant Service (`merchant-service`)
**Port:** 8011 | **DB:** PostgreSQL + MongoDB + Kafka

**Role:** Merchant profile, operating hours, bank accounts, menu management (categories + items)
**Endpoints:**
- Merchant CRUD + status
- Operating hours, bank accounts
- Menu categories (CRUD + reorder)
- Menu items (CRUD + availability toggle)
- Internal: Merchant lookup, is-open check, batch menu items

#### Promotion Service (`promotion-service`)
**Port:** 8013 | **DB:** PostgreSQL (GORM)

**Role:** Promo codes & vouchers
**Endpoints:** Validate promo, List/claim vouchers, Admin promo CRUD, Internal apply/release promo

#### Pricing Service (`pricing-service`)
**Port:** 8012 | **DB:** PostgreSQL (TODO)

**Role:** Fare estimation & surge pricing
**Endpoints:** Estimate ride/food/delivery fare, Surge pricing, Calculate final fare, Fare rules

### 4.8 Wallet & History Services

#### Wallet Service (`wallet-service`)
**Port:** 8022 | **DB:** PostgreSQL

**Role:** Digital wallet — balance, top-up, debit
**Endpoints:** Get balance, Top-up (with webhook callback), Transfer, Transactions, Driver settlement

#### Rating Service (`rating-service`)
**Port:** 8015 | **DB:** PostgreSQL (GORM)

**Role:** Rating & review system
**Endpoints:** Submit rating, Get ratings by subject/order, My given/received ratings, Driver score, Batch averages

**Models:** `Rating`, `DriverScoreAggregate`, `MerchantScoreAggregate` (auto-migrated)

#### History Service (`history-service`)
**Port:** 8023 | **DB:** PostgreSQL (GORM)

**Role:** Order history & activity feed
**Endpoints:** Order history, Transaction history, Activity feed, Driver trip/earnings history, Internal sync + feed creation

#### Tracking Service (`tracking-service`)
**Port:** 8006 | **DB:** MongoDB + Redis (cache)

**Role:** Real-time order tracking — driver position, ETA, route
**Endpoints:** Get position/ETA/route, Internal start/stop/push location

### 4.9 Security & Audit Services

#### Audit Log Service (`audit-log-service`)
**Port:** 8007 | **DB:** MongoDB

**Role:** Immutable audit log untuk compliance & debugging
**Endpoints:** Admin search, Get detail, Internal create (single + batch)

#### Security Service (`security-service`)
**Port:** 8020 | **DB:** PostgreSQL + Redis (TODO)

**Role:** Security monitoring, fraud detection, IP blacklisting
**Endpoints:** Login attempts, Fraud flags (CRUD + resolve), IP blacklist, Internal validate IP/user, Record login attempt

### 4.10 Shared Library (`clay-shared`)

**Module:** `backend/pkg/` — `github.com/zicofarry/clay-shared`

| Package | Description |
|---------|-------------|
| `pkg/response` | Standard JSON response: `Success()`, `Error()`, `Paginated()`, `Health()`, `JSON()` |
| `pkg/middleware` | HTTP middleware: `AuthContext()`, `RequestID()`, `Logger()`, `Recovery()`, `CORS()` |
| `pkg/kafka` | Event envelope (`Event{EventID, EventType, Source, Timestamp, Data}`), `Producer`/`Consumer` interfaces, `segmentio/kafka-go` impl, no-op impl |
| `pkg/database` | PostgreSQL/Redis/MongoDB config & connection helpers, `WithTransaction()` |
| `pkg/validator` | JSON decoding (`DecodeJSON`), query param parsing, pagination (`ParsePagination`) |
| `pkg/idempotency` | Redis-backed idempotency key checking (`Checker`, `Store` interface) |

---

## 5. Frontend Architecture (Android)

**Type:** Android Native (Kotlin + Jetpack Compose + Material 3)
**Modules:** 17 total (1 app + 5 core + 11 feature)

### Navigation Structure

```
ClayNavHost
├── AuthGraph (start)
│   ├── LoginScreen
│   ├── RegisterScreen
│   └── OtpScreen
└── MainGraph (bottom nav: Beranda | Aktivitas | Pesan | Akun)
    ├── HomeScreen (wallet card, service grid, promos, recent orders)
    ├── SearchScreen
    ├── Ride screens (destination → pickup → confirm → tracking)
    ├── Food screens (listing → detail → cart → checkout)
    ├── Send screen (package delivery)
    ├── Services screens (Pet, Waste, Care, Travel, Bills, Entertainment)
    ├── ActivityScreen (order history with filter chips)
    ├── Chat screens (list → detail)
    ├── Wallet screens (balance → topup → vouchers)
    ├── Profile screens (profile → settings → help)
    └── NotificationsScreen
```

### API Layer

**Base URL:** `http://10.0.2.2:8080/` (Android emulator → host localhost)
**Stack:** Retrofit 2.11 + OkHttp 4.12 + Moshi 1.15

**API Interfaces:**
| Interface | Base Path |
|-----------|-----------|
| `AuthApi` | `/api/v1/auth/*` |
| `UserApi` | `/api/v1/users/*`, `/api/v1/addresses/*` |
| `WalletApi` | `/api/v1/wallet/*`, `/api/v1/promotions/vouchers` |
| `RideOrderApi` | `/api/v1/ride/*` |
| `FoodOrderApi` | `/api/v1/food/*` |

**Current Status:** Retrofit interfaces defined, tapi repository implementations masih return **mock data** dengan `delay()`. Belum connect ke backend asli.

### Architecture Pattern
- **State Management:** Local state di Composable (`remember { mutableStateOf() }`)
- **DI:** Hilt modules (no ViewModels yet - semua state di screen langsung)
- **UI Components:** Reusable components di `core/ui/components/ClayComponents.kt`
- **Theming:** Material 3 light/dark color schemes + custom typography

---

## 6. Communication & Data Flow

### 6.1 Synchronous (HTTP)

**External → Internal:** Semua request dari client melewati Gateway (`:8080`).
Gateway me-route ke upstream service berdasarkan path YAML config.

**Service → Service (Internal):**
- Endpoint prefix `/internal/` bypass JWT auth gateway
- Contoh: Matching → Geo (nearby drivers), Payment → Wallet (debit)

### 6.2 Asynchronous (Kafka)

**Infrastructure:** Single Kafka cluster (Zookeeper + 1 broker + Kafka UI)
**Topic Naming:** `{domain}.{event}` (e.g., `payment.charged`, `driver.location_updated`)

**Event Flow:**

| Producer | Topics | Consumers |
|----------|--------|-----------|
| Auth Service | `auth.*` | Audit Log |
| Payment Service | `payment.charged/failed/refunded/held/captured/released`, `settlement.created` | Wallet, Audit Log, Notification |
| Matching Service | `driver.matched`, `driver.dispatched` | Ride Order, Notification |
| Geo Service | `driver.location_updated` | Tracking, Matching |
| Food Order Service | `food_order.*` | Audit Log, History, Notification |
| Ride Order Service | `order.created`, `order.completed` | Matching, Audit Log, History, Notification |
| Delivery Order Service | `delivery_order.*` | Audit Log, History, Notification |
| Merchant Service | `merchant.*` | Search, Audit Log |
| Security Service | `security.user_flagged` | Audit Log, Notification |

---

## 7. Infrastructure

### 7.1 Docker Compose

**File:** `backend/infra/docker-compose.yml` (1070 lines)

**Shared Infrastructure:**
```
Zookeeper (:2181) → Kafka (:9092/29092) → Kafka UI (:9000)
Elasticsearch (:9200)
Redis-gateway (:6370)
```

**Per Service:** Setiap service punya database sendiri:
- PostgreSQL 16 Alpine (17 services) dengan volume persisten
- MongoDB 7 (5 services) dengan volume persisten
- Redis 7 Alpine (18 services)
- Adminer (untuk PostgreSQL services)

**Network:** `clay-net` (bridge)

### 7.2 Kubernetes

**Directory:** `backend/infra/k8s/`

```
k8s/
├── base/
│   ├── namespace.yaml     # Namespace: clay
│   └── secrets.yaml       # Opaque: JWT secret, DB credentials
├── infra/
│   └── kafka.yaml         # Zookeeper + Kafka deployments & services
└── services/
    ├── gateway.yaml        # Deployment (2 replicas) + LoadBalancer service
    └── services.yaml       # 8 microservice deployments + ClusterIP services
```

**Deployment Pattern:**
- Replicas: 2 per service
- Readiness probe: `/health` (delay 5s, period 10s)
- Gateway also has liveness probe (delay 10s, period 15s)
- Resource requests: 100m CPU / 128Mi memory
- Resource limits: 500m CPU / 256Mi memory
- Strategy: RollingUpdate (default)

**Secrets:**
- `jwt-secret`: `clay-super-secret-key-change-in-production`
- `db-user` / `db-password`: `clay`

### 7.3 Port Mapping

| Service | App Port | PostgreSQL | Redis | MongoDB | Adminer |
|---------|:--------:|:----------:|:-----:|:-------:|:-------:|
| gateway | 8080 | - | 6370 | - | - |
| auth-service | 8001 | 5431 | 6371 | - | 9001 |
| user-service | 8002 | 5432 | 6372 | - | 9002 |
| email-service | 8003 | 5433 | 6373 | - | 9003 |
| payment-service | 8004 | 5434 | 6374 | - | 9004 |
| notification-service | 8005 | 5435 | - | - | 9005 |
| tracking-service | 8006 | - | 6376 | 27019 | - |
| audit-log-service | 8007 | - | - | 27018 | - |
| chat-service | 8008 | - | - | 27017 | - |
| geo-service | 8009 | 5439 | 6379 | - | 9009 |
| matching-service | 8010 | - | 6380 | - | - |
| merchant-service | 8011 | 5441 | - | 27020 | 9011 |
| pricing-service | 8012 | 5442 | 6382 | - | 9012 |
| promotion-service | 8013 | 5443 | 6383 | - | 9013 |
| push-service | 8014 | - | - | - | - |
| rating-service | 8015 | 5445 | 6385 | - | 9015 |
| ride-order-service | 8016 | 5446 | 6386 | - | 9016 |
| food-order-service | 8017 | 5447 | 6387 | 27021 | 9017 |
| delivery-order-service | 8018 | 5448 | 6388 | - | 9018 |
| search-service | 8019 | - | 6389 | - | - |
| security-service | 8020 | 5450 | 6390 | - | 9020 |
| sms-service | 8021 | 5451 | 6391 | - | 9021 |
| wallet-service | 8022 | 5452 | 6392 | - | 9022 |
| history-service | 8023 | 5453 | 6393 | - | 9023 |

**Shared Infrastructure:**
| Component | Port |
|-----------|:----:|
| Zookeeper | 2181 |
| Kafka (internal) | 9092 |
| Kafka (external) | 29092 |
| Elasticsearch | 9200 / 9300 |
| Kafka UI | 9000 |

---

## 8. CI/CD Pipeline

**File:** `Jenkinsfile` (276 lines)

**Platform:** Jenkins dengan Windows agents (bat commands)

**Strategy:** **Change-based conditional builds** — hanya service yang berubah yang dibuild & dideploy.

**Pipeline Stages:**
1. **Checkout** — `checkout scm`
2. **Build & Deploy (20 service stages)** — masing-masing pakai `when { changeset "..." }`
3. **Shared Library Warning** — jika `backend/pkg/` berubah
4. **Infrastructure** — jika `backend/infra/` berubah → `kubectl apply -f k8s/`

**Shared Function `buildAndDeploy(serviceDir, appName)`:**
```
1. go mod download
2. go test -tags=unit -v ./...
3. go vet ./...
4. docker build -t clay/<appName>:<BUILD_ID>
5. go test -tags=functional -v ./test/functional/...
6. docker push (build ID + latest)
7. kubectl set image deployment/<appName> <appName>=clay/<appName>:latest
8. kubectl rollout status deployment/<appName>
```

**Go Build Flags:** `CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -trimpath -ldflags="-s -w"`

**Image Registry:** `clay/<service-name>:latest`
**K8s Namespace:** `clay`

---

## 9. Data Warehouse Design

**Schema:** Fact Constellation (Galaxy Schema) — lihat [data_warehouse_design.md](data_warehouse_design.md) untuk detail lengkap.

### Fact Tables
| Table | Source Service | Measures |
|-------|---------------|----------|
| `Fact_Ride_Orders` | ride-order-service, payment-service | fare_final, distance_km, duration_min, surge_multiplier |
| `Fact_Food_Orders` | food-order-service, merchant-service, rating-service | subtotal, delivery_fee, discount, item_count, ratings |
| `Fact_Delivery_Orders` | delivery-order-service, payment-service | fare_final, distance_km, package_weight, platform_fee |

### Dimension Tables
| Table | Source |
|-------|--------|
| `Dim_Time` | Generated from timestamps |
| `Dim_User` | user-service (PostgreSQL) |
| `Dim_Driver` | user-service (PostgreSQL) |
| `Dim_Merchant` | merchant-service (PostgreSQL) |
| `Dim_Location` | geo-service + order addresses |
| `Dim_Payment_Method` | payment-service (PostgreSQL) |
| `Dim_Promotion` | promotion-service (PostgreSQL) |
| `Dim_Service_Type` | Static lookup |

### Database Roles
| Database | Peran di OLTP | Peran di DW |
|----------|--------------|-------------|
| PostgreSQL | ACID transactions, data utama | **Sumber utama** fact & dimension tables |
| MongoDB | Flexible schema (menu, chat, tracking) | Sumber food order items & merchant menu |
| Redis | Real-time cache, rate limiting | **Tidak langsung masuk DW** |
| Kafka | Event streaming | Bisa jadi transport layer untuk streaming ETL |

### ETL Pipeline
```
Microservices (PostgreSQL/MongoDB)
    → CDC / Batch Query
    → Transform (Clean, Denormalize, Enrich)
    → Load ke Data Warehouse
    → Analytics (Dashboard, Reports, ML)
```

---

## 10. Development Setup

### Prerequisites
- Go 1.25+
- Docker & Docker Compose
- Kubernetes (kind/minikube for local)
- Android Studio (untuk frontend)

### Running Locally

**1. Start infrastructure (Kafka, dll):**
```bash
cd backend/infra
docker-compose up -d zookeeper kafka kafka-ui
```

**2. Start service + database:**
```bash
# Start specific service with its dependencies
cd backend/services/auth-service
docker-compose up -d  # starts PostgreSQL + Redis
go run .              # runs service on :8001
```

**3. Start Gateway:**
```bash
cd backend/services/gateway
go run .
# Routes traffic from :8080 to upstream services
```

**4. Or start everything:**
```bash
cd backend/infra
docker-compose up -d  # starts all 24 services + databases
```

### Running Tests
```bash
# Unit tests (build tag: unit)
go test -tags=unit -v ./...

# Functional tests (build tag: functional)
go test -tags=functional -v ./test/functional/...
```

### Workspace Configuration (backend/go.work)
```go
go 1.25.0

use (
    ./services/auth-service
    ./services/user-service
    // ... all 24 services + ./pkg
)
```

### Service Template (setiap service mengikuti pola ini)
```
service-name/
├── main.go              # Entry point, router setup
├── internal/
│   ├── handler/         # HTTP handlers
│   ├── service/         # Business logic (interface-based)
│   ├── repository/      # Data access
│   ├── model/           # Data models (optional)
│   ├── broker/          # Kafka producer/consumer (optional)
│   └── cache/           # Redis cache (optional)
├── Dockerfile           # Multi-stage build
├── docker-compose.yml   # Local dependencies
└── go.mod
```

### Middleware Stack (applied di semua service)
```
CORS → RequestID → Recovery → Logger → AuthContext → Handler
```

### Common Environment Variables
```env
PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_USER=clay
DB_PASSWORD=clay
DB_NAME=clay_db
REDIS_HOST=localhost
REDIS_PORT=6379
MONGO_URI=mongodb://localhost:27017
KAFKA_BROKERS=localhost:9092
KAFKA_DISABLED=true  # Set true for local dev
```

---

## Key Architectural Patterns

1. **Database-per-Service:** Setiap service punya database instance sendiri (isolasi data)
2. **API Gateway Pattern:** Single entry point, YAML-based routing, centralized auth & rate limiting
3. **Event-Driven:** Kafka untuk async communication antar services
4. **Consistent Layered Architecture:** Handler → Service → Repository di setiap service
5. **Standard Library HTTP:** Semua service pakai Go stdlib `net/http`, tanpa framework eksternal
6. **Interface-Based Services:** Service layer menggunakan interface untuk testability (`go.uber.org/mock`)
7. **Change-Based CI/CD:** Jenkins hanya build service yang berubah
8. **Multi-Stage Docker Builds:** Golang builder → Alpine/distroless runtime
9. **State in URL:** `/internal/` prefix untuk service-to-service calls (bypass gateway auth)
10. **Idempotency:** Redis-backed idempotency key untuk payment operations

---

## Status & Gaps

### Implemented
- ✅ 24 Go microservices dengan code structure lengkap
- ✅ Android frontend dengan semua screen + navigation
- ✅ Docker Compose untuk semua service + infrastruktur
- ✅ K8s manifests untuk deployment
- ✅ Jenkins CI/CD pipeline
- ✅ Data Warehouse design (Fact Constellation)
- ✅ Kafka event contracts design
- ✅ Shared library (middleware, response, kafka, database helpers)

### Not Yet Implemented (TODO)
- ❌ Protobuf definitions (proto/ empty)
- ❌ Frontend belum connect ke backend (masih mock data)
- ❌ Kafka integration di beberapa service (masih LogProducer/NoopProducer)
- ❌ Database connections di beberapa service (masih `nil`)
- ❌ FCM/APNs SDK di push-service
- ❌ WebSocket untuk real-time chat
- ❌ Monitoring & observability (Prometheus, Grafana, tracing)
- ❌ Terraform / Infrastructure-as-Code
- ❌ Multi-environment (dev/staging/prod)
- ❌ Helm / Kustomize overlays
- ❌ Network policies, RBAC, security contexts di K8s
- ❌ Horizontal Pod Autoscaler
- ❌ Ingress controller & TLS
- ❌ Unit tests di banyak service
