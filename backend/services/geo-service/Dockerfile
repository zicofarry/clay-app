FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install dependencies for building
RUN apk add --no-cache git tzdata

# Copy the entire backend directory to have access to pkg and go.work
COPY go.work go.work.sum ./
COPY pkg/ ./pkg/
COPY services/geo-service/ ./services/geo-service/

# Build the binary using go workspace resolution (no vendor folder needed)
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /geo-service ./services/geo-service/main.go

# Final stage
FROM alpine:3.19

WORKDIR /root/

# Copy timezone data and certs
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy built binary
COPY --from=builder /geo-service .

ENV PORT=8080
EXPOSE 8080

CMD ["./geo-service"]
