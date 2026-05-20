# ── Stage 1: Build ───────────────────────────────────────────────────────────
FROM golang:1.23-alpine AS builder

WORKDIR /workspace

# Copy clay-shared first (local replace directive)
COPY clay-shared/ clay-shared/

# Copy gateway source
COPY clay-gateway/ clay-gateway/

WORKDIR /workspace/clay-gateway

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /gateway .

# ── Stage 2: Runtime ──────────────────────────────────────────────────────────
FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=builder /gateway /app/gateway
COPY --from=builder /workspace/clay-gateway/config/routes.yaml /app/config/routes.yaml

EXPOSE 8080

ENTRYPOINT ["/app/gateway"]
