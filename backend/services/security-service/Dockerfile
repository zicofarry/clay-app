FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git tzdata

COPY . .

RUN if [ -d vendor ]; then \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /security-service ./main.go; \
    else \
      CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /security-service ./main.go; \
    fi

FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /security-service .

ENV PORT=8020
EXPOSE 8020

CMD ["./security-service"]
