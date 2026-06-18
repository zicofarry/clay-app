package client

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"time"

	"github.com/zicofarry/clay-app/backend/services/ride-order-service/internal/service"
)

// MatchingClient implements service.MatchingClientInterface via HTTP.
type MatchingClient struct {
	baseURL    string
	httpClient *http.Client
	logger     *slog.Logger
}

func NewMatchingClient(baseURL string, logger *slog.Logger) *MatchingClient {
	return &MatchingClient{
		baseURL: baseURL,
		httpClient: &http.Client{
			Timeout: 5 * time.Second,
		},
		logger: logger,
	}
}

func (c *MatchingClient) StartDispatch(ctx context.Context, req *service.DispatchMatchRequest) error {
	body, err := json.Marshal(req)
	if err != nil {
		return fmt.Errorf("marshal dispatch request: %w", err)
	}

	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/internal/dispatcher/dispatch", bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create dispatch request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("dispatch call failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("dispatch returned status %d", resp.StatusCode)
	}

	return nil
}

func (c *MatchingClient) FreeDriver(ctx context.Context, driverID string) error {
	url := fmt.Sprintf("%s/internal/drivers/%s/free", c.baseURL, driverID)
	httpReq, err := http.NewRequestWithContext(ctx, http.MethodPut, url, bytes.NewReader([]byte(`{}`)))
	if err != nil {
		return fmt.Errorf("create free-driver request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	resp, err := c.httpClient.Do(httpReq)
	if err != nil {
		return fmt.Errorf("free-driver call failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		return fmt.Errorf("free-driver returned status %d", resp.StatusCode)
	}
	return nil
}
