module github.com/zicofarry/clay-gateway

go 1.23.0

require (
	github.com/golang-jwt/jwt/v5 v5.2.1
	github.com/redis/go-redis/v9 v9.5.1
	github.com/zicofarry/clay-shared v0.0.0
	gopkg.in/yaml.v3 v3.0.1
)

require (
	github.com/bsm/redislock v0.9.4 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/dgryski/go-rendezvous v0.0.0-20200823014737-9f7001d12a5f // indirect
	github.com/google/uuid v1.6.0 // indirect
)

replace github.com/zicofarry/clay-shared => ../clay-shared
