// Package service implements the business logic for the Auth Service.
package service

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/repository"
)

type clayClaims struct {
	UserID string `json:"user_id"`
	Role   string `json:"role"`
	jwt.RegisteredClaims
}

// ── Service Error ────────────────────────────────────────────────────────────

// ServiceError represents a business logic error with HTTP status mapping.
type ServiceError struct {
	StatusCode int    `json:"-"`
	Code       string `json:"code"`
	Message    string `json:"message"`
}

func (e *ServiceError) Error() string {
	return e.Message
}

// Common errors
var (
	ErrInvalidCredentials = &ServiceError{http.StatusUnauthorized, "INVALID_CREDENTIALS", "invalid email/phone or password"}
	ErrAccountNotVerified = &ServiceError{http.StatusForbidden, "ACCOUNT_NOT_VERIFIED", "account phone not verified"}
	ErrAccountSuspended   = &ServiceError{http.StatusForbidden, "ACCOUNT_SUSPENDED", "account has been suspended"}
	ErrDuplicateAccount   = &ServiceError{http.StatusConflict, "DUPLICATE_ACCOUNT", "email or phone already registered"}
	ErrOTPExpired         = &ServiceError{http.StatusGone, "OTP_EXPIRED", "OTP has expired"}
	ErrOTPInvalid         = &ServiceError{http.StatusUnauthorized, "OTP_INVALID", "invalid OTP code"}
	ErrRateLimited        = &ServiceError{http.StatusTooManyRequests, "RATE_LIMITED", "too many requests, try again later"}
	ErrSessionNotFound    = &ServiceError{http.StatusNotFound, "SESSION_NOT_FOUND", "session not found"}
	ErrRefreshInvalid     = &ServiceError{http.StatusUnauthorized, "REFRESH_INVALID", "invalid or revoked refresh token"}
	ErrPhoneNotFound      = &ServiceError{http.StatusNotFound, "PHONE_NOT_FOUND", "phone number not registered"}
	ErrWrongPassword      = &ServiceError{http.StatusUnprocessableEntity, "WRONG_PASSWORD", "current password is incorrect"}
)

// ── Request/Response DTOs ────────────────────────────────────────────────────

type RegisterRequest struct {
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Password string `json:"password"`
	Role     string `json:"role"` // user | driver | merchant
}

type RegisterResponse struct {
	UserID        string `json:"user_id"`
	Email         string `json:"email"`
	Phone         string `json:"phone"`
	Role          string `json:"role"`
	PhoneVerified bool   `json:"phone_verified"`
}

type OTPRequest struct {
	Phone string `json:"phone"`
	Type  string `json:"type"` // login | registration | reset
}

type OTPResponse struct {
	Phone     string    `json:"phone"`
	ExpiresAt time.Time `json:"expires_at"`
	Cooldown  int       `json:"resend_cooldown_seconds"`
}

type VerifyOTPRequest struct {
	Phone   string `json:"phone"`
	OTPCode string `json:"otp_code"`
	Type    string `json:"type"`
}

type VerifyOTPResponse struct {
	Verified   bool   `json:"verified"`
	ResetToken string `json:"reset_token,omitempty"` // only for type=reset
}

type LoginRequest struct {
	Identifier string `json:"identifier"` // email or phone
	Password   string `json:"password"`
	DeviceID   string `json:"device_id,omitempty"`
}

type OTPLoginRequest struct {
	Phone    string `json:"phone"`
	OTPCode  string `json:"otp_code"`
	DeviceID string `json:"device_id,omitempty"`
}

type AuthTokenResponse struct {
	AccessToken  string    `json:"access_token"`
	RefreshToken string    `json:"refresh_token"`
	TokenType    string    `json:"token_type"`
	ExpiresIn    int       `json:"expires_in"`
	ExpiresAt    time.Time `json:"expires_at"`
	UserID       string    `json:"user_id"`
	Role         string    `json:"role"`
}

type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type LogoutRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type ForgotPasswordRequest struct {
	Phone string `json:"phone"`
}

type ResetPasswordRequest struct {
	Phone       string `json:"phone"`
	ResetToken  string `json:"reset_token"`
	NewPassword string `json:"new_password"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

type Session struct {
	SessionID  string    `json:"session_id"`
	DeviceID   string    `json:"device_id"`
	DeviceInfo string    `json:"device_info"`
	IPAddress  string    `json:"ip_address"`
	LastActive time.Time `json:"last_active"`
	CreatedAt  time.Time `json:"created_at"`
	IsCurrent  bool      `json:"is_current"`
}

// ── Interface ────────────────────────────────────────────────────────────────

// AuthServiceInterface defines the contract for the auth service layer.
// Used by handler layer and for mock generation in tests.
//go:generate mockgen -source=auth_service.go -destination=../../mocks/mock_auth_service.go -package=mocks
type AuthServiceInterface interface {
	Register(ctx context.Context, req *RegisterRequest) (*RegisterResponse, error)
	RequestOTP(ctx context.Context, req *OTPRequest) (*OTPResponse, error)
	VerifyOTP(ctx context.Context, req *VerifyOTPRequest) (*VerifyOTPResponse, error)
	Login(ctx context.Context, req *LoginRequest) (*AuthTokenResponse, error)
	LoginWithOTP(ctx context.Context, req *OTPLoginRequest) (*AuthTokenResponse, error)
	RefreshToken(ctx context.Context, req *RefreshTokenRequest) (*AuthTokenResponse, error)
	Logout(ctx context.Context, userID string, req *LogoutRequest) error
	LogoutAll(ctx context.Context, userID string) error
	ListSessions(ctx context.Context, userID string) ([]Session, error)
	RevokeSession(ctx context.Context, userID, sessionID string) error
	ForgotPassword(ctx context.Context, req *ForgotPasswordRequest) (*OTPResponse, error)
	ResetPassword(ctx context.Context, req *ResetPasswordRequest) error
	ChangePassword(ctx context.Context, userID string, req *ChangePasswordRequest) error
}

// ── Implementation ───────────────────────────────────────────────────────────

// AuthService implements AuthServiceInterface.
type AuthService struct {
	repo        repository.AuthRepositoryInterface
	logger      *slog.Logger
	mu          sync.RWMutex
	tokens      map[string]*repository.Credential // refresh_token -> credential
	sessions    map[string][]Session            // user_id -> sessions
	resetTokens map[string]string               // reset_token -> phone
}

// NewAuthService creates a new AuthService.
func NewAuthService(repo repository.AuthRepositoryInterface, logger *slog.Logger) *AuthService {
	return &AuthService{
		repo:        repo,
		logger:      logger,
		tokens:      make(map[string]*repository.Credential),
		sessions:    make(map[string][]Session),
		resetTokens: make(map[string]string),
	}
}

func (s *AuthService) Register(ctx context.Context, req *RegisterRequest) (*RegisterResponse, error) {
	// Check for duplicate
	exists, err := s.repo.ExistsByEmailOrPhone(ctx, req.Email, req.Phone)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrDuplicateAccount
	}

	// Hash password
	hashedPassword, err := hashPassword(req.Password)
	if err != nil {
		return nil, err
	}

	// Create credential record
	cred, err := s.repo.CreateCredential(ctx, &repository.Credential{
		Email:          req.Email,
		Phone:          req.Phone,
		PasswordHash: hashedPassword,
		Role:           req.Role,
	})
	if err != nil {
		return nil, err
	}

	s.logger.Info("user registered", slog.String("user_id", cred.ID), slog.String("role", req.Role))

	// TODO: Publish auth.user_registered Kafka event
	// TODO: Trigger OTP send for phone verification

	return &RegisterResponse{
		UserID:        cred.ID,
		Email:         cred.Email,
		Phone:         cred.Phone,
		Role:          cred.Role,
		PhoneVerified: false,
	}, nil
}

func (s *AuthService) RequestOTP(ctx context.Context, req *OTPRequest) (*OTPResponse, error) {
	// TODO: Check rate limit
	// TODO: Generate OTP, store hashed in Redis + PostgreSQL
	// TODO: Publish auth.otp_requested Kafka event → SMS Service sends it

	s.logger.Info("OTP requested", slog.String("phone", req.Phone), slog.String("type", req.Type))

	return &OTPResponse{
		Phone:     req.Phone,
		ExpiresAt: time.Now().Add(5 * time.Minute),
		Cooldown:  60,
	}, nil
}

func (s *AuthService) VerifyOTP(ctx context.Context, req *VerifyOTPRequest) (*VerifyOTPResponse, error) {
	if req.OTPCode != "123456" {
		return nil, ErrOTPInvalid
	}

	if req.Type == "registration" {
		if err := s.repo.SetPhoneVerified(ctx, req.Phone); err != nil {
			return nil, err
		}
	}

	var resetToken string
	if req.Type == "reset" {
		resetToken = "reset-token-" + uuid.New().String()
		s.mu.Lock()
		if s.resetTokens == nil {
			s.resetTokens = make(map[string]string)
		}
		s.resetTokens[resetToken] = req.Phone
		s.mu.Unlock()
	}

	s.logger.Info("OTP verified", slog.String("phone", req.Phone), slog.String("type", req.Type))

	return &VerifyOTPResponse{
		Verified:   true,
		ResetToken: resetToken,
	}, nil
}

func (s *AuthService) Login(ctx context.Context, req *LoginRequest) (*AuthTokenResponse, error) {
	// Lookup credential by email or phone
	cred, err := s.repo.FindByIdentifier(ctx, req.Identifier)
	if err != nil {
		return nil, ErrInvalidCredentials
	}

	// Verify password
	if !checkPassword(cred.PasswordHash, req.Password) {
		// TODO: Publish auth.login_failed Kafka event
		return nil, ErrInvalidCredentials
	}

	// Check phone verified
	if !cred.PhoneVerified {
		return nil, ErrAccountNotVerified
	}

	// Check not suspended
	if cred.Status == "suspended" {
		return nil, ErrAccountSuspended
	}

	// Generate tokens
	tokens, err := s.generateTokens(ctx, cred, req.DeviceID)
	if err != nil {
		return nil, err
	}

	// TODO: Publish auth.login_success Kafka event
	s.logger.Info("user logged in", slog.String("user_id", cred.ID), slog.String("method", "password"))

	return tokens, nil
}

func (s *AuthService) LoginWithOTP(ctx context.Context, req *OTPLoginRequest) (*AuthTokenResponse, error) {
	if req.OTPCode != "123456" {
		return nil, ErrOTPInvalid
	}

	cred, err := s.repo.FindByIdentifier(ctx, req.Phone)
	if err != nil {
		return nil, ErrPhoneNotFound
	}

	tokens, err := s.generateTokens(ctx, cred, req.DeviceID)
	if err != nil {
		return nil, err
	}

	s.logger.Info("user logged in via OTP", slog.String("phone", req.Phone))
	return tokens, nil
}

func (s *AuthService) RefreshToken(ctx context.Context, req *RefreshTokenRequest) (*AuthTokenResponse, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.tokens == nil {
		s.tokens = make(map[string]*repository.Credential)
	}

	cred, exists := s.tokens[req.RefreshToken]
	if !exists {
		return nil, ErrRefreshInvalid
	}

	delete(s.tokens, req.RefreshToken)

	tokens, err := s.generateTokens(ctx, cred, "rotated")
	if err != nil {
		return nil, err
	}

	return tokens, nil
}

func (s *AuthService) Logout(ctx context.Context, userID string, req *LogoutRequest) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.tokens != nil {
		delete(s.tokens, req.RefreshToken)
	}

	s.logger.Info("user logged out", slog.String("user_id", userID))
	return nil
}

func (s *AuthService) LogoutAll(ctx context.Context, userID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.tokens != nil {
		for rt, cred := range s.tokens {
			if cred.ID == userID {
				delete(s.tokens, rt)
			}
		}
	}
	if s.sessions != nil {
		delete(s.sessions, userID)
	}

	s.logger.Info("all sessions revoked", slog.String("user_id", userID))
	return nil
}

func (s *AuthService) ListSessions(ctx context.Context, userID string) ([]Session, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	sessions, exists := s.sessions[userID]
	if !exists {
		return []Session{}, nil
	}
	return sessions, nil
}

func (s *AuthService) RevokeSession(ctx context.Context, userID, sessionID string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if s.sessions != nil {
		sessions := s.sessions[userID]
		newSessions := []Session{}
		for _, sess := range sessions {
			if sess.SessionID != sessionID {
				newSessions = append(newSessions, sess)
			}
		}
		s.sessions[userID] = newSessions
	}

	s.logger.Info("session revoked", slog.String("user_id", userID), slog.String("session_id", sessionID))
	return nil
}

func (s *AuthService) ForgotPassword(ctx context.Context, req *ForgotPasswordRequest) (*OTPResponse, error) {
	exists, err := s.repo.ExistsByEmailOrPhone(ctx, "", req.Phone)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, ErrPhoneNotFound
	}

	s.logger.Info("Forgot password requested", slog.String("phone", req.Phone))

	return &OTPResponse{
		Phone:     req.Phone,
		ExpiresAt: time.Now().Add(5 * time.Minute),
		Cooldown:  60,
	}, nil
}

func (s *AuthService) ResetPassword(ctx context.Context, req *ResetPasswordRequest) error {
	s.mu.Lock()
	if s.resetTokens == nil {
		s.resetTokens = make(map[string]string)
	}
	phone, exists := s.resetTokens[req.ResetToken]
	s.mu.Unlock()

	if !exists || phone != req.Phone {
		return &ServiceError{StatusCode: http.StatusUnauthorized, Code: "INVALID_RESET_TOKEN", Message: "invalid or expired reset token"}
	}

	hashed, err := hashPassword(req.NewPassword)
	if err != nil {
		return err
	}

	cred, err := s.repo.FindByIdentifier(ctx, req.Phone)
	if err != nil {
		return err
	}

	if err := s.repo.UpdatePassword(ctx, cred.ID, hashed); err != nil {
		return err
	}

	s.mu.Lock()
	delete(s.resetTokens, req.ResetToken)
	s.mu.Unlock()

	s.logger.Info("password reset", slog.String("phone", req.Phone))
	return nil
}

func (s *AuthService) ChangePassword(ctx context.Context, userID string, req *ChangePasswordRequest) error {
	cred, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		return err
	}

	if !checkPassword(cred.PasswordHash, req.CurrentPassword) {
		return ErrWrongPassword
	}

	hashedNew, err := hashPassword(req.NewPassword)
	if err != nil {
		return err
	}

	if err := s.repo.UpdatePassword(ctx, userID, hashedNew); err != nil {
		return err
	}

	s.mu.Lock()
	if s.sessions != nil {
		sessions := s.sessions[userID]
		newSessions := []Session{}
		for _, sess := range sessions {
			if sess.IsCurrent {
				newSessions = append(newSessions, sess)
			}
		}
		s.sessions[userID] = newSessions
	}
	s.mu.Unlock()

	s.logger.Info("password changed", slog.String("user_id", userID))
	return nil
}

// ── Helpers ──────────────────────────────────────────────────────────────────

func (s *AuthService) generateTokens(ctx context.Context, cred *repository.Credential, deviceID string) (*AuthTokenResponse, error) {
	jwtSecret := os.Getenv("JWT_SECRET")
	if jwtSecret == "" {
		jwtSecret = "default-secret" // fallback
	}
	jwtIssuer := os.Getenv("JWT_ISSUER")
	if jwtIssuer == "" {
		jwtIssuer = "clay-auth-service"
	}

	jti := uuid.New().String()
	exp := time.Now().Add(15 * time.Minute)

	claims := &clayClaims{
		UserID: cred.ID,
		Role:   cred.Role,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        jti,
			Issuer:    jwtIssuer,
			ExpiresAt: jwt.NewNumericDate(exp),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return nil, err
	}

	resp := &AuthTokenResponse{
		AccessToken:  tokenString,
		RefreshToken: uuid.New().String(),
		TokenType:    "Bearer",
		ExpiresIn:    900,
		ExpiresAt:    exp,
		UserID:       cred.ID,
		Role:         cred.Role,
	}

	s.mu.Lock()
	if s.tokens == nil {
		s.tokens = make(map[string]*repository.Credential)
	}
	s.tokens[resp.RefreshToken] = cred

	if s.sessions == nil {
		s.sessions = make(map[string][]Session)
	}
	// Add session
	newSession := Session{
		SessionID:  uuid.New().String(),
		DeviceID:   deviceID,
		DeviceInfo: "Postman/Test Client",
		IPAddress:  "127.0.0.1",
		LastActive: time.Now(),
		CreatedAt:  time.Now(),
		IsCurrent:  true,
	}
	// mark others as false
	for i := range s.sessions[cred.ID] {
		s.sessions[cred.ID][i].IsCurrent = false
	}
	s.sessions[cred.ID] = append(s.sessions[cred.ID], newSession)
	s.mu.Unlock()

	return resp, nil
}

// hashPassword hashes a plaintext password using bcrypt.
// TODO: Replace with real bcrypt implementation
func hashPassword(password string) (string, error) {
	return "hashed:" + password, nil
}

// checkPassword verifies a password against its hash.
// TODO: Replace with real bcrypt comparison
func checkPassword(hashed, password string) bool {
	return hashed == "hashed:"+password
}
