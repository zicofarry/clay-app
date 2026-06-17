package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/zicofarry/clay-app/backend/pkg/acs"
	"github.com/zicofarry/clay-app/backend/services/email-service/internal/model"
	"github.com/zicofarry/clay-app/backend/services/email-service/internal/repository"
)

var (
	ErrTemplateNotFound = errors.New("template not found")
	ErrRateLimitExceeded = errors.New("rate limit exceeded for recipient")
)

type EmailService interface {
	SendEmail(ctx context.Context, idempotencyKey string, req model.SendEmailRequest) (*model.SendEmailResponse, error)
	GetEmailStatus(ctx context.Context, emailId string) (*model.EmailStatusResponse, error)
	HandleWebhook(ctx context.Context, payload map[string]interface{}) error
	GetTemplates(ctx context.Context) ([]model.EmailTemplate, error)
	UpsertTemplate(ctx context.Context, req model.UpsertTemplateRequest) (*model.EmailTemplate, error)
}

type emailService struct {
	repo     repository.EmailRepository
	acs      *acs.Client
	acsReady bool
	logger   *slog.Logger
}

func NewEmailService(repo repository.EmailRepository, logger *slog.Logger) EmailService {
	svc := &emailService{
		repo:   repo,
		logger: logger,
	}

	if cfg, ok := acs.ConfigFromEnv(); ok && cfg.EmailFrom != "" {
		svc.acs = acs.NewClient(*cfg)
		svc.acsReady = true
		logger.Info("ACS Email client initialized",
			slog.String("from", cfg.EmailFrom),
		)
	} else {
		logger.Info("ACS not configured, emails will be logged to console")
	}

	return svc
}

func (s *emailService) SendEmail(ctx context.Context, idempotencyKey string, req model.SendEmailRequest) (*model.SendEmailResponse, error) {
	s.logger.Info("sending email", slog.String("to", req.To), slog.String("template_id", string(req.TemplateId)))

	template, err := s.repo.GetTemplate(ctx, req.TemplateId)
	if err != nil {
		if errors.Is(err, repository.ErrTemplateNotFound) {
			return nil, ErrTemplateNotFound
		}
		return nil, err
	}

	subject := renderTemplate(template.Subject, req.Variables)
	html := renderTemplate(template.BodyHtml, req.Variables)

	emailId := uuid.New().String()
	now := time.Now()

	status := model.EmailStatusResponse{
		EmailId:    emailId,
		Status:     "queued",
		ProviderId: "acs-" + uuid.New().String(),
		SentAt:     &now,
	}

	if s.acsReady {
		go func() {
			if err := s.acs.SendEmail(req.To, subject, html); err != nil {
				s.logger.Error("ACS email failed",
					slog.String("email_id", emailId),
					slog.Any("error", err),
				)
			} else {
				s.logger.Info("Email sent via ACS", slog.String("email_id", emailId), slog.String("to", req.To))
			}
		}()
	} else {
		s.logger.Info("Email (logged, ACS not configured)",
			slog.String("to", req.To),
			slog.String("subject", subject),
			slog.String("html", html),
		)
	}

	if err := s.repo.SaveEmailLog(ctx, status); err != nil {
		return nil, err
	}

	return &model.SendEmailResponse{
		EmailId:  emailId,
		Status:   "queued",
		Provider: "acs",
	}, nil
}

func renderTemplate(tmpl string, vars map[string]interface{}) string {
	result := tmpl
	for k, v := range vars {
		placeholder := fmt.Sprintf("{{%s}}", k)
		result = strings.ReplaceAll(result, placeholder, fmt.Sprintf("%v", v))
	}
	return result
}

func (s *emailService) GetEmailStatus(ctx context.Context, emailId string) (*model.EmailStatusResponse, error) {
	return s.repo.GetEmailStatus(ctx, emailId)
}

func (s *emailService) HandleWebhook(ctx context.Context, payload map[string]interface{}) error {
	s.logger.Info("received webhook", slog.Any("payload", payload))

	// Mock webhook processing (e.g. from Sendgrid)
	// Extract provider_id and event
	providerId, okId := payload["sg_message_id"].(string)
	event, okEvent := payload["event"].(string)

	if !okId || !okEvent {
		return errors.New("invalid webhook payload")
	}

	// Map sendgrid event to our status
	status := "sent"
	if event == "delivered" {
		status = "delivered"
	} else if event == "bounce" {
		status = "bounced"
	} else if event == "spamreport" {
		status = "spam"
	}

	return s.repo.UpdateEmailStatus(ctx, providerId, status)
}

func (s *emailService) GetTemplates(ctx context.Context) ([]model.EmailTemplate, error) {
	return s.repo.GetTemplates(ctx)
}

func (s *emailService) UpsertTemplate(ctx context.Context, req model.UpsertTemplateRequest) (*model.EmailTemplate, error) {
	now := time.Now()
	template := model.EmailTemplate{
		TemplateId: req.TemplateId,
		Subject:    req.Subject,
		BodyHtml:   req.BodyHtml,
		UpdatedAt:  &now,
	}

	err := s.repo.UpsertTemplate(ctx, template)
	if err != nil {
		return nil, err
	}

	return &template, nil
}
