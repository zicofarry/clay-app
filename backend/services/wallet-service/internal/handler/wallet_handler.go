package handler

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/zicofarry/clay-app/backend/pkg/response"
	"github.com/zicofarry/clay-app/backend/services/wallet-service/internal/service"
)

type WalletHandler struct {
	svc            service.WalletService
	userServiceURL string
	httpClient     *http.Client
}

func NewWalletHandler(svc service.WalletService, userServiceURL string) *WalletHandler {
	return &WalletHandler{
		svc:            svc,
		userServiceURL: userServiceURL,
		httpClient:     &http.Client{Timeout: 5 * time.Second},
	}
}

func (h *WalletHandler) GetWallet(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.Header.Get("X-User-ID")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_USER_ID", "Invalid X-User-ID header")
		return
	}

	wallet, err := h.svc.GetBalance(r.Context(), userID)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to get wallet")
		return
	}

	response.JSON(w, http.StatusOK, map[string]interface{}{
		"wallet_id":  wallet.ID,
		"user_id":    wallet.UserID,
		"balance":    wallet.Balance,
		"is_active":  wallet.IsActive,
		"created_at": wallet.CreatedAt,
	})
}

func (h *WalletHandler) TopUp(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.Header.Get("X-User-ID")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_USER_ID", "Invalid X-User-ID header")
		return
	}

	var req struct {
		Amount  int64  `json:"amount"`
		Channel string `json:"channel"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	tx, err := h.svc.TopUp(r.Context(), userID, req.Amount, req.Channel)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to top up")
		return
	}

	response.JSON(w, http.StatusCreated, map[string]interface{}{
		"transaction_id": tx.ID,
		"amount":         tx.Amount,
		"channel":        req.Channel,
		"redirect_url":   "https://gateway.example.com/pay/" + tx.ID.String(),
	})
}

func (h *WalletHandler) Debit(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID      uuid.UUID `json:"user_id"`
		Amount      int64     `json:"amount"`
		ReferenceID uuid.UUID `json:"reference_id"`
		Description string    `json:"description"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	tx, err := h.svc.Debit(r.Context(), req.UserID, req.Amount, req.ReferenceID, req.Description)
	if err != nil {
		response.Error(w, http.StatusPaymentRequired, "INSUFFICIENT_BALANCE", err.Error())
		return
	}

	response.JSON(w, http.StatusOK, map[string]interface{}{
		"tx_id":          tx.ID,
		"balance_after":  tx.BalanceAfter,
		"balance_before": tx.BalanceAfter + tx.Amount,
		"amount":         tx.Amount,
	})
}

func (h *WalletHandler) Transfer(w http.ResponseWriter, r *http.Request) {
	senderIDStr := r.Header.Get("X-User-ID")
	senderID, err := uuid.Parse(senderIDStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_USER_ID", "Invalid X-User-ID header")
		return
	}

	var req struct {
		RecipientPhone string `json:"recipient_phone"`
		Amount         int64  `json:"amount"`
		Note           string `json:"note"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_REQUEST", "Invalid request body")
		return
	}

	if req.RecipientPhone == "" {
		response.Error(w, http.StatusBadRequest, "MISSING_RECIPIENT", "recipient_phone is required")
		return
	}

	if req.Amount < 1000 {
		response.Error(w, http.StatusBadRequest, "INVALID_AMOUNT", "Minimum transfer amount is Rp 1.000")
		return
	}

	recipientID, err := h.lookupUserByPhone(req.RecipientPhone)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "RECIPIENT_NOT_FOUND", "Recipient phone number not found")
		return
	}

	senderTx, _, err := h.svc.Transfer(r.Context(), senderID, recipientID, req.Amount, req.Note)
	if err != nil {
		if err.Error() == "cannot transfer to yourself" {
			response.Error(w, http.StatusBadRequest, "SELF_TRANSFER", err.Error())
			return
		}
		if err.Error() == "insufficient balance" {
			response.Error(w, http.StatusPaymentRequired, "INSUFFICIENT_BALANCE", err.Error())
			return
		}
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to transfer")
		return
	}

	response.JSON(w, http.StatusOK, map[string]interface{}{
		"transaction_id": senderTx.ID,
		"amount":         req.Amount,
		"balance_after":  senderTx.BalanceAfter,
		"recipient":      req.RecipientPhone,
	})
}

func (h *WalletHandler) GetTransactions(w http.ResponseWriter, r *http.Request) {
	userIDStr := r.Header.Get("X-User-ID")
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		response.Error(w, http.StatusBadRequest, "INVALID_USER_ID", "Invalid X-User-ID header")
		return
	}

	page := 1
	limit := 20
	if p := r.URL.Query().Get("page"); p != "" {
		if v, err := strconv.Atoi(p); err == nil && v > 0 {
			page = v
		}
	}
	if l := r.URL.Query().Get("limit"); l != "" {
		if v, err := strconv.Atoi(l); err == nil && v > 0 && v <= 100 {
			limit = v
		}
	}

	txs, total, err := h.svc.GetTransactions(r.Context(), userID, page, limit)
	if err != nil {
		response.Error(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Failed to get transactions")
		return
	}

	result := make([]map[string]interface{}, 0, len(txs))
	for _, tx := range txs {
		result = append(result, map[string]interface{}{
			"id":             tx.ID,
			"type":           tx.Type,
			"amount":         tx.Amount,
			"balance_after":  tx.BalanceAfter,
			"description":    tx.Description,
			"created_at":     tx.CreatedAt,
		})
	}

	response.JSON(w, http.StatusOK, map[string]interface{}{
		"data": result,
		"meta": map[string]interface{}{
			"page":  page,
			"limit": limit,
			"total": total,
		},
	})
}

func (h *WalletHandler) lookupUserByPhone(phone string) (uuid.UUID, error) {
	body := map[string]string{"phone": phone}
	jsonBody, err := json.Marshal(body)
	if err != nil {
		return uuid.UUID{}, err
	}

	url := fmt.Sprintf("%s/internal/users/lookup-by-phone", h.userServiceURL)
	req, err := http.NewRequest("POST", url, bytes.NewReader(jsonBody))
	if err != nil {
		return uuid.UUID{}, err
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := h.httpClient.Do(req)
	if err != nil {
		return uuid.UUID{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return uuid.UUID{}, fmt.Errorf("user service returned status %d", resp.StatusCode)
	}

	var result struct {
		Success bool `json:"success"`
		Data    struct {
			Found  bool       `json:"found"`
			UserID *uuid.UUID `json:"user_id"`
		} `json:"data"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return uuid.UUID{}, err
	}

	if !result.Data.Found || result.Data.UserID == nil {
		return uuid.UUID{}, fmt.Errorf("user not found")
	}

	return *result.Data.UserID, nil
}
