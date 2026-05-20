FROM golang:1.25-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git tzdata

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=vendor -o /promotion-service ./main.go

FROM alpine:3.19

WORKDIR /root/

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /promotion-service .

ENV PORT=8013
EXPOSE 8013

CMD ["./promotion-service"]
