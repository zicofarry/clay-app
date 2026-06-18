package handler

import (
	"encoding/json"
	"net/http"
	"strings"

	"github.com/zicofarry/clay-app/backend/pkg/response"
	"github.com/zicofarry/clay-app/backend/services/auth-service/internal/repository"
)

type InternalHandler struct {
	repo repository.AuthRepositoryInterface
}

func NewInternalHandler(repo repository.AuthRepositoryInterface) *InternalHandler {
	return &InternalHandler{repo: repo}
}

func (h *InternalHandler) LookupByPhone(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Phone string `json:"phone"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil || req.Phone == "" {
		response.Error(w, http.StatusBadRequest, "BAD_REQUEST", "phone is required")
		return
	}

	phone := strings.TrimSpace(req.Phone)
	phones := []string{phone}
	if strings.HasPrefix(phone, "0") {
		phones = append(phones, "+62"+phone[1:])
	} else if !strings.HasPrefix(phone, "+") {
		phones = append(phones, "+62"+phone)
	}

	for _, p := range phones {
		cred, err := h.repo.FindByIdentifier(r.Context(), p)
		if err == nil && cred != nil {
			response.Success(w, http.StatusOK, map[string]interface{}{
				"found":   true,
				"user_id": cred.ID,
			})
			return
		}
	}

	response.Success(w, http.StatusOK, map[string]interface{}{
		"found": false,
	})
}
