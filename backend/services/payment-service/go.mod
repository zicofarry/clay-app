module github.com/zicofarry/clay-payment-service

go 1.25.0

replace github.com/zicofarry/clay-shared => ../clay-shared

require (
	github.com/DATA-DOG/go-sqlmock v1.5.2
	github.com/lib/pq v1.12.3
	github.com/zicofarry/clay-shared v0.0.0-00010101000000-000000000000
	go.uber.org/mock v0.5.0
)

require github.com/google/uuid v1.6.0 // indirect
