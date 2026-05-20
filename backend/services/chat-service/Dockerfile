FROM golang:1.25-alpine AS builder

WORKDIR /app

# Install dependencies for building
RUN apk add --no-cache git tzdata

# Copy all source code including the vendor directory
COPY . .

# Build the binary using the vendor folder
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /chat-service ./main.go

# Final stage
FROM alpine:3.19

WORKDIR /root/

# Copy timezone data and certs
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy built binary
COPY --from=builder /chat-service .

ENV PORT=8008
EXPOSE 8008

CMD ["./chat-service"]
