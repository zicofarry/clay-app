package handler

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	"github.com/google/uuid"
	"github.com/zicofarry/clay-app/backend/pkg/middleware"
	"github.com/zicofarry/clay-app/backend/pkg/response"
	"github.com/zicofarry/clay-app/backend/services/user-service/internal/models"
	"github.com/zicofarry/clay-app/backend/services/user-service/internal/service"
)

type UserHandler struct {
	svc             service.UserServiceInterface
	uploadsDir      string
	publicURLPrefix string
	authServiceURL  string
}

type HandlerOption func(*UserHandler)

func WithUploadsDir(dir string) HandlerOption {
	return func(h *UserHandler) { h.uploadsDir = dir }
}

func WithPublicURLPrefix(prefix string) HandlerOption {
	return func(h *UserHandler) { h.publicURLPrefix = prefix }
}

func WithAuthServiceURL(url string) HandlerOption {
	return func(h *UserHandler) { h.authServiceURL = url }
}

func NewUserHandler(svc service.UserServiceInterface, opts ...HandlerOption) *UserHandler {
	h := &UserHandler{
		svc:             svc,
		uploadsDir:      "./data/uploads",
		publicURLPrefix: "/users/me/avatar/file",
	}
	for _, opt := range opts {
		opt(h)
	}
	return h
}

// Mocking getting UserID from context. In a real app, middleware sets this.
func getUserIDFromContext(ctx context.Context) uuid.UUID {
	userIDStr := middleware.GetUserID(ctx)
	if userIDStr != "" {
		if id, err := uuid.Parse(userIDStr); err == nil {
			return id
		}
	}
	return uuid.MustParse("00000000-0000-0000-0000-000000000001")
}

func getPathVar(r *http.Request, key string) string {
	return r.PathValue(key)
}

// ── Profile ──────────────────────────────────────────────────────────────────

func (h *UserHandler) GetMyProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	profile, err := h.svc.GetProfile(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) CreateProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.CreateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.CreateProfile(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusConflict, "CONFLICT", err.Error())
		return
	}
	response.Success(w, http.StatusCreated, profile)
}

func (h *UserHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.UpdateProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.UpdateProfile(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) GetProfileByUserId(w http.ResponseWriter, r *http.Request) {
	idStr := getPathVar(r, "userId")
	userID, err := uuid.Parse(idStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.GetPublicProfile(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) UploadAvatar(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	if err := r.ParseMultipartForm(2 << 20); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", "avatar terlalu besar (maks 2MB)")
		return
	}
	file, header, err := r.FormFile("avatar")
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", "field 'avatar' wajib diisi")
		return
	}
	defer file.Close()

	ct := header.Header.Get("Content-Type")
	switch ct {
	case "image/jpeg", "image/png", "image/webp":
		// ok
	default:
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", "format foto harus jpeg/png/webp")
		return
	}

	if err := os.MkdirAll(h.uploadsDir, 0o755); err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}

	ext := ".jpg"
	switch ct {
	case "image/png":
		ext = ".png"
	case "image/webp":
		ext = ".webp"
	}
	filename := userID.String() + ext
	dstPath := filepath.Join(h.uploadsDir, filename)

	dst, err := os.Create(dstPath)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	defer dst.Close()
	if _, err := io.Copy(dst, file); err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}

	avatarURL := h.publicURLPrefix

	_, err = h.svc.SetAvatarURL(r.Context(), userID, avatarURL)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"avatar_url": avatarURL})
}

func (h *UserHandler) ServeAvatar(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	for _, ext := range []string{".jpg", ".png", ".webp"} {
		path := filepath.Join(h.uploadsDir, userID.String()+ext)
		if _, err := os.Stat(path); err == nil {
			switch ext {
			case ".png":
				w.Header().Set("Content-Type", "image/png")
			case ".webp":
				w.Header().Set("Content-Type", "image/webp")
			default:
				w.Header().Set("Content-Type", "image/jpeg")
			}
			w.Header().Set("Cache-Control", "public, max-age=300")
			http.ServeFile(w, r, path)
			return
		}
	}
	http.NotFound(w, r)
}

func (h *UserHandler) ApplyReferralCode(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req struct {
		ReferralCode string `json:"referral_code"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	err := h.svc.ApplyReferralCode(r.Context(), userID, req.ReferralCode)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Referral applied"})
}

// ── Address ──────────────────────────────────────────────────────────────────

func (h *UserHandler) ListAddresses(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	addresses, err := h.svc.ListAddresses(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	resp := models.AddressListResponse{
		Status: "success",
		Data:   addresses,
	}
	if addresses == nil {
		resp.Data = []models.AddressResponse{}
	}
	response.Success(w, http.StatusOK, resp)
}

func (h *UserHandler) CreateAddress(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.AddressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	addr, err := h.svc.CreateAddress(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusCreated, addr)
}

func (h *UserHandler) UpdateAddress(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	addrID, err := uuid.Parse(getPathVar(r, "addressId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	var req models.AddressRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	addr, err := h.svc.UpdateAddress(r.Context(), userID, addrID, req)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, addr)
}

func (h *UserHandler) DeleteAddress(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	addrID, err := uuid.Parse(getPathVar(r, "addressId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	err = h.svc.DeleteAddress(r.Context(), userID, addrID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Address deleted"})
}

func (h *UserHandler) SetDefaultAddress(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	addrID, err := uuid.Parse(getPathVar(r, "addressId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	err = h.svc.SetDefaultAddress(r.Context(), userID, addrID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Default address updated"})
}

// ── Driver ───────────────────────────────────────────────────────────────────

func (h *UserHandler) GetDriverProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	profile, err := h.svc.GetDriverProfile(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) CreateDriverProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.CreateDriverProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.CreateDriverProfile(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusConflict, "CONFLICT", err.Error())
		return
	}
	response.Success(w, http.StatusCreated, profile)
}

func (h *UserHandler) UpdateDriverProfile(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.UpdateDriverProfileRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.UpdateDriverProfile(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) GetDriverProfileById(w http.ResponseWriter, r *http.Request) {
	idStr := getPathVar(r, "driverId")
	driverID, err := uuid.Parse(idStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.GetPublicDriverProfile(r.Context(), driverID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, profile)
}

func (h *UserHandler) ToggleDriverOnline(w http.ResponseWriter, r *http.Request) {
	driverID, err := uuid.Parse(getPathVar(r, "driverId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	var req struct {
		IsOnline bool `json:"is_online"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	profile, err := h.svc.ToggleDriverOnline(r.Context(), driverID, req.IsOnline)
	if err != nil {
		response.Error(w, http.StatusForbidden, "FORBIDDEN", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]interface{}{
		"status": "success",
		"data": map[string]interface{}{
			"is_online":      profile.IsOnline,
			"last_online_at": profile.LastOnlineAt,
		},
	})
}

// ── Driver Documents ─────────────────────────────────────────────────────────

func (h *UserHandler) ListDriverDocuments(w http.ResponseWriter, r *http.Request) {
	driverID := getUserIDFromContext(r.Context())
	docs, err := h.svc.ListDriverDocuments(r.Context(), driverID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	resp := models.DocumentListResponse{
		Status: "success",
		Data:   docs,
	}
	if docs == nil {
		resp.Data = []models.DocumentResponse{}
	}
	response.Success(w, http.StatusOK, resp)
}

func (h *UserHandler) UploadDocument(w http.ResponseWriter, r *http.Request) {
	driverID := getUserIDFromContext(r.Context())
	var req struct {
		Type string `json:"type"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	doc, err := h.svc.UploadDocument(r.Context(), driverID, req.Type, "https://example.com/doc.jpg")
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusCreated, doc)
}

func (h *UserHandler) GetDocument(w http.ResponseWriter, r *http.Request) {
	docID, err := uuid.Parse(getPathVar(r, "documentId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	doc, err := h.svc.GetDocument(r.Context(), docID)
	if err != nil {
		response.Error(w, http.StatusNotFound, "NOT_FOUND", err.Error())
		return
	}
	response.Success(w, http.StatusOK, doc)
}

func (h *UserHandler) DeleteDocument(w http.ResponseWriter, r *http.Request) {
	driverID := getUserIDFromContext(r.Context())
	docID, err := uuid.Parse(getPathVar(r, "documentId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	err = h.svc.DeleteDocument(r.Context(), driverID, docID)
	if err != nil {
		response.Error(w, http.StatusForbidden, "FORBIDDEN", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Document deleted"})
}

// ── Admin Documents ──────────────────────────────────────────────────────────

func (h *UserHandler) GetDriverVerificationStatus(w http.ResponseWriter, r *http.Request) {
	driverID, err := uuid.Parse(getPathVar(r, "driverId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	docs, err := h.svc.GetDriverVerificationStatus(r.Context(), driverID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	resp := models.DocumentListResponse{
		Status: "success",
		Data:   docs,
	}
	if docs == nil {
		resp.Data = []models.DocumentResponse{}
	}
	response.Success(w, http.StatusOK, resp)
}

func (h *UserHandler) VerifyDocument(w http.ResponseWriter, r *http.Request) {
	docID, err := uuid.Parse(getPathVar(r, "documentId"))
	if err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	var req struct {
		Status          string `json:"status"`
		RejectionReason string `json:"rejection_reason"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	doc, err := h.svc.VerifyDocument(r.Context(), docID, req.Status, req.RejectionReason)
	if err != nil {
		response.Error(w, http.StatusForbidden, "FORBIDDEN", err.Error())
		return
	}
	response.Success(w, http.StatusOK, doc)
}

// ── Settings ─────────────────────────────────────────────────────────────────

func (h *UserHandler) GetSettings(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	settings, err := h.svc.GetSettings(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, settings)
}

func (h *UserHandler) UpdateSettings(w http.ResponseWriter, r *http.Request) {
	userID := getUserIDFromContext(r.Context())
	var req models.UpdateSettingsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}
	settings, err := h.svc.UpdateSettings(r.Context(), userID, req)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, settings)
}

// ── Internal ─────────────────────────────────────────────────────────────────

func (h *UserHandler) LookupUserByPhone(w http.ResponseWriter, r *http.Request) {
	var req models.LookupUserByPhoneRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", err.Error())
		return
	}

	if h.authServiceURL == "" {
		response.Error(w, http.StatusInternalServerError, "CONFIG_ERROR", "auth service URL not configured")
		return
	}

	authBody, _ := json.Marshal(map[string]string{"phone": req.Phone})
	authResp, err := http.Post(
		fmt.Sprintf("%s/internal/auth/lookup-by-phone", h.authServiceURL),
		"application/json",
		bytes.NewReader(authBody),
	)
	if err != nil {
		response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{Found: false})
		return
	}
	defer authResp.Body.Close()

	var authResult struct {
		Success bool `json:"success"`
		Data    struct {
			Found  bool   `json:"found"`
			UserID string `json:"user_id"`
		} `json:"data"`
	}
	if err := json.NewDecoder(authResp.Body).Decode(&authResult); err != nil {
		response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{Found: false})
		return
	}

	if !authResult.Data.Found {
		response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{Found: false})
		return
	}

	userID, err := uuid.Parse(authResult.Data.UserID)
	if err != nil {
		response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{Found: false})
		return
	}

	profile, err := h.svc.GetProfile(r.Context(), userID)
	if err != nil || profile == nil {
		response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{
			Found:  true,
			UserID: &userID,
		})
		return
	}

	response.Success(w, http.StatusOK, &models.LookupUserByPhoneResponse{
		Found:    true,
		UserID:   &userID,
		FullName: profile.FullName,
	})
}
