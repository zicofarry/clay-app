FROM golang:1.25-alpine AS builder

WORKDIR /app

# Build deps
RUN apk add --no-cache git tzdata

# Copy source (vendor dir included for offline / reproducible builds).
COPY . .

# Build the binary using vendor when present, otherwise pull modules.
RUN if [ -d vendor ]; then \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /matching-service ./main.go; \
    else \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /matching-service ./main.go; \
    fi

# Final stage
FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /matching-service .

ENV PORT=8010
EXPOSE 8010

CMD ["./matching-service"]
