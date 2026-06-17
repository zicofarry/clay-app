package otp

import (
	"context"
	"crypto/rand"
	"errors"
	"fmt"
	"math/big"
	"time"

	"github.com/redis/go-redis/v9"
)

var (
	ErrOTPNotFound   = errors.New("OTP not found or expired")
	ErrOTPInvalid    = errors.New("invalid OTP code")
	ErrRateLimited   = errors.New("too many OTP requests, try again later")
)

type Store struct {
	rdb redis.UniversalClient
}

func NewStore(rdb redis.UniversalClient) *Store {
	return &Store{rdb: rdb}
}

func generateCode() (string, error) {
	max := big.NewInt(1000000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return "", fmt.Errorf("generate OTP: %w", err)
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}

func otpKey(contact, purpose string) string {
	return "otp:" + contact + ":" + purpose
}

func rateLimitKey(contact string) string {
	return "otp:ratelimit:" + contact
}

func (s *Store) Generate(ctx context.Context, contact, purpose string) (string, time.Duration, error) {
	count, err := s.rdb.Incr(ctx, rateLimitKey(contact)).Result()
	if err != nil {
		return "", 0, fmt.Errorf("rate limit check: %w", err)
	}
	if count == 1 {
		s.rdb.Expire(ctx, rateLimitKey(contact), time.Minute)
	}
	if count > 3 {
		return "", 0, ErrRateLimited
	}

	code, err := generateCode()
	if err != nil {
		return "", 0, err
	}

	ttl := 5 * time.Minute
	if err := s.rdb.Set(ctx, otpKey(contact, purpose), code, ttl).Err(); err != nil {
		return "", 0, fmt.Errorf("store OTP: %w", err)
	}

	return code, ttl, nil
}

func (s *Store) Verify(ctx context.Context, contact, purpose, code string) error {
	key := otpKey(contact, purpose)
	stored, err := s.rdb.Get(ctx, key).Result()
	if err == redis.Nil {
		return ErrOTPNotFound
	}
	if err != nil {
		return fmt.Errorf("get OTP: %w", err)
	}

	if stored != code {
		return ErrOTPInvalid
	}

	s.rdb.Del(ctx, key)
	return nil
}

func (s *Store) Peek(ctx context.Context, contact, purpose string) (string, error) {
	return s.rdb.Get(ctx, otpKey(contact, purpose)).Result()
}

func (s *Store) Delete(ctx context.Context, contact, purpose string) error {
	return s.rdb.Del(ctx, otpKey(contact, purpose)).Err()
}
