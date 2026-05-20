FROM golang:1.25-alpine AS builder

WORKDIR /app

# Build deps
RUN apk add --no-cache git tzdata

# Copy source (vendor dir included for offline / reproducible builds).
COPY . .

# Build the binary using vendor when present, otherwise pull modules.
RUN if [ -d vendor ]; then \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /ride-order-service ./main.go; \
    else \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /ride-order-service ./main.go; \
    fi

# Final stage
FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /ride-order-service .

ENV PORT=3003
EXPOSE 3003

CMD ["./ride-order-service"]
