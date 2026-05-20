FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git tzdata

COPY . .

RUN if [ -d vendor ]; then \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /delivery-order-service ./main.go; \
    else \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /delivery-order-service ./main.go; \
    fi

FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /delivery-order-service .

ENV PORT=3004
EXPOSE 3004

CMD ["./delivery-order-service"]
