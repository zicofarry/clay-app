package sender

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"
)

type Sender struct {
	smsServiceURL   string
	emailServiceURL string
	client          *http.Client
	logger          *slog.Logger
}

func NewSender(logger *slog.Logger) *Sender {
	return &Sender{
		smsServiceURL:   os.Getenv("SMS_SERVICE_URL"),
		emailServiceURL: os.Getenv("EMAIL_SERVICE_URL"),
		client: &http.Client{
			Timeout: 10 * time.Second,
		},
		logger: logger,
	}
}

type SendSMSRequest struct {
	To      string `json:"to"`
	Message string `json:"message"`
}

type SendEmailRequest struct {
	To         string                 `json:"to"`
	TemplateID string                 `json:"template_id"`
	Variables  map[string]interface{} `json:"variables"`
}

func isPhoneNumber(s string) bool {
	if len(s) == 0 {
		return false
	}
	for _, r := range s {
		if r != '+' && r != '-' && r != ' ' && r != '(' && r != ')' && (r < '0' || r > '9') {
			return false
		}
	}
	digits := 0
	for _, r := range s {
		if r >= '0' && r <= '9' {
			digits++
		}
	}
	return digits >= 8
}

func (s *Sender) SendOTP(ctx context.Context, contact, otpCode, purpose string) {
	if isPhoneNumber(contact) {
		message := fmt.Sprintf("[Clay] Kode OTP Anda: %s. Berlaku 5 menit. Jangan bagikan kode ini kepada siapa pun.", otpCode)
		if s.smsServiceURL != "" {
			if err := s.callSMSService(ctx, contact, message); err != nil {
				s.logger.Error("failed to send SMS via service", slog.Any("error", err))
			}
		}
	} else {
		if s.emailServiceURL != "" {
			if err := s.callEmailService(ctx, contact, otpCode, purpose); err != nil {
				s.logger.Error("failed to send email via service", slog.Any("error", err))
			}
		}
	}

	s.logger.Info("OTP sent",
		slog.String("contact", contact),
		slog.String("otp_code", otpCode),
		slog.String("purpose", purpose),
	)
}

func (s *Sender) callSMSService(ctx context.Context, phone, message string) error {
	body, _ := json.Marshal(SendSMSRequest{To: phone, Message: message})
	req, err := http.NewRequestWithContext(ctx, "POST", s.smsServiceURL+"/internal/sms/send", bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create SMS request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Idempotency-Key", fmt.Sprintf("otp-%s-%d", phone, time.Now().UnixNano()))

	resp, err := s.client.Do(req)
	if err != nil {
		return fmt.Errorf("call SMS service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("SMS service returned status %d", resp.StatusCode)
	}
	return nil
}

func (s *Sender) callEmailService(ctx context.Context, email, otpCode, purpose string) error {
	purposeLabel := map[string]string{
		"registration": "Pendaftaran Akun",
		"reset":        "Reset Kata Sandi",
		"login":        "Login",
	}

	templateID := "otp_login"
	varName := "otp_code"
	if purpose == "registration" {
		templateID = "email_verification"
		varName = "verification_code"
	}

	body, _ := json.Marshal(SendEmailRequest{
		To:         email,
		TemplateID: templateID,
		Variables: map[string]interface{}{
			varName: otpCode,
			"purpose": purposeLabel[purpose],
			"valid_minutes": 5,
		},
	})

	req, err := http.NewRequestWithContext(ctx, "POST", s.emailServiceURL+"/internal/emails/send", bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create email request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Idempotency-Key", fmt.Sprintf("otp-%s-%d", email, time.Now().UnixNano()))

	resp, err := s.client.Do(req)
	if err != nil {
		return fmt.Errorf("call email service: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("email service returned status %d", resp.StatusCode)
	}
	return nil
}
