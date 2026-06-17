package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"

	"github.com/zicofarry/clay-app/backend/services/email-service/internal/handler"
	"github.com/zicofarry/clay-app/backend/services/email-service/internal/model"
	"github.com/zicofarry/clay-app/backend/services/email-service/internal/repository"
	"github.com/zicofarry/clay-app/backend/services/email-service/internal/service"
	"github.com/zicofarry/clay-app/backend/pkg/middleware"
	"github.com/zicofarry/clay-app/backend/pkg/response"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))
	slog.SetDefault(logger)

	redisUrl := os.Getenv("REDIS_URL")
	if redisUrl == "" {
		redisUrl = "redis://localhost:6373/0"
	}
	emailRepo := repository.NewEmailRepository(redisUrl)
	emailSvc := service.NewEmailService(emailRepo, logger)
	emailHandler := handler.NewEmailHandler(emailSvc)

	// ── Seed Templates ───────────────────────────────────────────────────
	ctx := context.Background()
	templates := []struct {
		id      model.EmailTemplateId
		subject string
		html    string
	}{
		{
			id:      model.OTPLoginTemplate,
			subject: "Kode OTP Login - Clay",
			html: `<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
<h2 style="color: #0A84FF;">Clay</h2>
<p>Gunakan kode OTP berikut untuk login:</p>
<div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 24px; background: #f5f5f5; border-radius: 12px; margin: 16px 0;">{{otp_code}}</div>
<p>Kode berlaku <strong>{{valid_minutes}} menit</strong>. Jangan bagikan kode ini kepada siapa pun.</p>
<p style="color: #999; font-size: 12px;">Jika Anda tidak meminta kode ini, abaikan email ini.</p>
</div>`,
		},
		{
			id:      model.EmailVerificationTemplate,
			subject: "Verifikasi Email - Clay",
			html: `<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
<h2 style="color: #0A84FF;">Clay</h2>
<p>Terima kasih telah mendaftar! Gunakan kode berikut untuk memverifikasi email Anda:</p>
<div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 24px; background: #f5f5f5; border-radius: 12px; margin: 16px 0;">{{verification_code}}</div>
<p>Kode berlaku <strong>{{valid_minutes}} menit</strong>.</p>
<p style="color: #999; font-size: 12px;">Jika Anda tidak mendaftar, abaikan email ini.</p>
</div>`,
		},
		{
			id:      model.PasswordResetTemplate,
			subject: "Reset Kata Sandi - Clay",
			html: `<div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto;">
<h2 style="color: #0A84FF;">Clay</h2>
<p>Anda menerima permintaan reset kata sandi. Gunakan kode OTP berikut:</p>
<div style="font-size: 32px; font-weight: bold; letter-spacing: 8px; text-align: center; padding: 24px; background: #f5f5f5; border-radius: 12px; margin: 16px 0;">{{otp_code}}</div>
<p>Kode berlaku <strong>{{valid_minutes}} menit</strong>.</p>
<p style="color: #999; font-size: 12px;">Jika Anda tidak meminta reset kata sandi, abaikan email ini.</p>
</div>`,
		},
	}

	for _, t := range templates {
		if _, err := emailSvc.UpsertTemplate(ctx, model.UpsertTemplateRequest{
			TemplateId: t.id,
			Subject:    t.subject,
			BodyHtml:   t.html,
		}); err != nil {
			logger.Error("failed to seed template", slog.String("template_id", string(t.id)), slog.Any("error", err))
		} else {
			logger.Info("seeded template", slog.String("template_id", string(t.id)))
		}
	}

	// ── Router ───────────────────────────────────────────────────────────
	mux := http.NewServeMux()

	// Health
	mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
		response.Health(w, "1.0.0")
	})

	// Emails
	mux.HandleFunc("POST /internal/emails/send", emailHandler.SendEmail)
	mux.HandleFunc("GET /internal/emails/{emailId}/status", emailHandler.GetEmailStatus)

	// Webhooks
	mux.HandleFunc("POST /webhooks/email/delivery", emailHandler.HandleWebhook)

	// Templates
	mux.HandleFunc("GET /templates", emailHandler.GetTemplates)
	mux.HandleFunc("POST /templates", emailHandler.UpsertTemplate)

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

	logger.Info("starting clay-email-service", slog.String("port", port))
	if err := http.ListenAndServe(":"+port, h); err != nil {
		logger.Error("server failed", slog.Any("error", err))
		os.Exit(1)
	}
}
