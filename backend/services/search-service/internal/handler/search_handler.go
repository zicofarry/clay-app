package handler

import (
	"encoding/json"
	"net/http"

	"github.com/zicofarry/clay-app/backend/pkg/response"
	"github.com/zicofarry/clay-app/backend/services/search-service/internal/model"
	"github.com/zicofarry/clay-app/backend/services/search-service/internal/service"
)

type SearchHandler struct {
	service service.SearchServiceInterface
}

func NewSearchHandler(svc service.SearchServiceInterface) *SearchHandler {
	return &SearchHandler{
		service: svc,
	}
}

func (h *SearchHandler) SearchMerchants(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	res, err := h.service.SearchMerchants(r.Context(), map[string]string{"q": q})
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, res)
}

func (h *SearchHandler) SearchMenuItems(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query().Get("q")
	res, err := h.service.SearchMenuItems(r.Context(), map[string]string{"q": q})
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, res)
}

func (h *SearchHandler) GetTrending(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusOK, map[string]string{"message": "GetTrending endpoint"})
}

func (h *SearchHandler) SearchSuggest(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusOK, map[string]string{"message": "SearchSuggest endpoint"})
}

func (h *SearchHandler) GetPopular(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusOK, map[string]string{"message": "GetPopular endpoint"})
}

func (h *SearchHandler) IndexMerchant(w http.ResponseWriter, r *http.Request) {
	var doc model.MerchantDocument
	if err := json.NewDecoder(r.Body).Decode(&doc); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_INPUT", "invalid payload: "+err.Error())
		return
	}
	if err := h.service.IndexMerchant(r.Context(), doc); err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Merchant indexed successfully"})
}

func (h *SearchHandler) DeleteMerchantIndex(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusOK, map[string]string{"message": "DeleteMerchantIndex endpoint"})
}

func (h *SearchHandler) IndexMenuItem(w http.ResponseWriter, r *http.Request) {
	var doc model.MenuItemDocument
	if err := json.NewDecoder(r.Body).Decode(&doc); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_INPUT", "invalid payload: "+err.Error())
		return
	}
	if err := h.service.IndexMenuItem(r.Context(), doc); err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", err.Error())
		return
	}
	response.Success(w, http.StatusOK, map[string]string{"message": "Menu item indexed successfully"})
}

func (h *SearchHandler) DeleteMenuItemIndex(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusOK, map[string]string{"message": "DeleteMenuItemIndex endpoint"})
}

func (h *SearchHandler) TriggerReindex(w http.ResponseWriter, r *http.Request) {
	response.Success(w, http.StatusAccepted, map[string]string{"message": "Reindex job started"})
}
