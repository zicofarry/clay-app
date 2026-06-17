package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"

	"github.com/redis/go-redis/v9"
	_ "github.com/lib/pq"
	"github.com/zicofarry/clay-app/backend/pkg/database"
	"github.com/zicofarry/clay-app/backend/pkg/middleware"
	"github.com/zicofarry/clay-app/backend/pkg/response"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/handler"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/otp"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/repository"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/sender"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/service"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	slog.SetDefault(logger)

	// ── PostgreSQL ───────────────────────────────────────────────────────
	pgConfig := database.DefaultPostgresConfig()
	db, err := database.NewPostgresDB(pgConfig)
	if err != nil {
		logger.Error("failed to connect to postgres", slog.Any("error", err))
		os.Exit(1)
	}
	defer db.Close()

	// ── Redis ────────────────────────────────────────────────────────────
	var redisOpts *redis.Options
	redisURL := os.Getenv("REDIS_URL")
	if redisURL != "" {
		opts, err := redis.ParseURL(redisURL)
		if err != nil {
			logger.Error("failed to parse redis url", slog.Any("error", err))
			os.Exit(1)
		}
		redisOpts = opts
	} else {
		redisAddr := os.Getenv("REDIS_ADDR")
		if redisAddr == "" {
			redisAddr = "localhost:6379"
		}
		redisOpts = &redis.Options{Addr: redisAddr}
	}

	rdb := redis.NewClient(redisOpts)
	defer rdb.Close()
	if err := rdb.Ping(context.Background()).Err(); err != nil {
		logger.Error("failed to connect to redis", slog.Any("error", err))
		os.Exit(1)
	}

	// ── Dependencies ─────────────────────────────────────────────────────
	authRepo := repository.NewAuthRepository(db, rdb)
	otpStore := otp.NewStore(rdb)
	msgSender := sender.NewSender(logger)
	authSvc := service.NewAuthService(authRepo, otpStore, msgSender, logger)
	authHandler := handler.NewAuthHandler(authSvc)

	// ── Router ───────────────────────────────────────────────────────────
	mux := http.NewServeMux()

	// Health
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		response.Health(w, "1.0.0")
	})

	// Registration
	mux.HandleFunc("POST /auth/register", authHandler.Register)

	// OTP
	mux.HandleFunc("POST /auth/request-otp", authHandler.RequestOTP)
	mux.HandleFunc("POST /auth/verify-otp", authHandler.VerifyOTP)

	// Login
	mux.HandleFunc("POST /auth/login", authHandler.Login)
	mux.HandleFunc("POST /auth/login/otp", authHandler.LoginWithOTP)

	// Token
	mux.HandleFunc("POST /auth/refresh-token", authHandler.RefreshToken)

	// Logout
	mux.HandleFunc("POST /auth/logout", authHandler.Logout)
	mux.HandleFunc("POST /auth/logout-all", authHandler.LogoutAll)
	mux.HandleFunc("POST /auth/sessions/revoke-all", authHandler.LogoutAll)

	// Sessions
	mux.HandleFunc("GET /auth/sessions", authHandler.ListSessions)
	mux.HandleFunc("DELETE /auth/sessions/{sessionId}", authHandler.RevokeSession)

	// Password
	mux.HandleFunc("POST /auth/password/forgot", authHandler.ForgotPassword)
	mux.HandleFunc("POST /auth/password/reset", authHandler.ResetPassword)
	mux.HandleFunc("PUT /auth/password/change", authHandler.ChangePassword)

	// ── Middleware Stack ──────────────────────────────────────────────────
	var h http.Handler = mux
	h = middleware.Logger(logger)(h)
	h = middleware.Recovery(logger)(h)
	h = middleware.RequestID(h)
	h = middleware.CORS(middleware.DefaultCORSConfig())(h)

	// ── Start Server ─────────────────────────────────────────────────────
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	logger.Info("starting clay-auth-service", slog.String("port", port))
	if err := http.ListenAndServe(":"+port, h); err != nil {
		logger.Error("server failed", slog.Any("error", err))
		os.Exit(1)
	}
}
