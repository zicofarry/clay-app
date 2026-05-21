//go:build functional

package functional

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"testing"
	"time"
)

var gatewayURL string

func TestMain(m *testing.M) {
	port := envOrDefault("GATEWAY_TEST_PORT", "18080")
	gatewayURL = fmt.Sprintf("http://localhost:%s", port)

	// Start gateway binary in background for testing
	cmd := exec.Command("go", "run", "./main.go")
	cmd.Dir = "../../"
	cmd.Env = append(os.Environ(),
		fmt.Sprintf("PORT=%s", port),
		"REDIS_ADDR=localhost:6370",
		"JWT_SECRET=test-secret",
		"CORS_ORIGINS=*",
	)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		fmt.Printf("failed to start gateway: %v\n", err)
		os.Exit(1)
	}

	// Wait for gateway to be ready
	ready := false
	for i := 0; i < 15; i++ {
		resp, err := http.Get(gatewayURL + "/health")
		if err == nil && resp.StatusCode == http.StatusOK {
			resp.Body.Close()
			ready = true
			break
		}
		time.Sleep(1 * time.Second)
	}

	if !ready {
		fmt.Println("gateway did not become ready in time")
		_ = cmd.Process.Kill()
		os.Exit(1)
	}

	code := m.Run()

	_ = cmd.Process.Kill()
	os.Exit(code)
}

// ─── Health Check ────────────────────────────────────────────────────────────

func TestHealthEndpoint(t *testing.T) {
	resp, err := http.Get(gatewayURL + "/health")
	if err != nil {
		t.Fatalf("health request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected status 200, got %d", resp.StatusCode)
	}

	var body map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("failed to decode health response: %v", err)
	}

	if body["status"] != "ok" {
		t.Errorf("expected status 'ok', got %q", body["status"])
	}
	if body["service"] != "clay-gateway" {
		t.Errorf("expected service 'clay-gateway', got %q", body["service"])
	}
}

// ─── CORS ────────────────────────────────────────────────────────────────────

func TestCORSPreflight(t *testing.T) {
	req, _ := http.NewRequest(http.MethodOptions, gatewayURL+"/health", nil)
	req.Header.Set("Origin", "http://localhost:3000")
	req.Header.Set("Access-Control-Request-Method", "GET")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("CORS preflight request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent {
		t.Fatalf("expected status 204 for OPTIONS, got %d", resp.StatusCode)
	}

	acaoHeader := resp.Header.Get("Access-Control-Allow-Origin")
	if acaoHeader == "" {
		t.Error("missing Access-Control-Allow-Origin header")
	}
}

// ─── 404 Not Found ──────────────────────────────────────────────────────────

func TestNotFoundRoute(t *testing.T) {
	resp, err := http.Get(gatewayURL + "/this-route-does-not-exist")
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNotFound {
		t.Fatalf("expected status 404, got %d", resp.StatusCode)
	}

	var body map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatalf("failed to decode 404 response: %v", err)
	}

	if body["code"] != "NOT_FOUND" {
		t.Errorf("expected code 'NOT_FOUND', got %q", body["code"])
	}
}

// ─── Request ID Header ──────────────────────────────────────────────────────

func TestRequestIDHeader(t *testing.T) {
	resp, err := http.Get(gatewayURL + "/health")
	if err != nil {
		t.Fatalf("request failed: %v", err)
	}
	defer resp.Body.Close()

	reqID := resp.Header.Get("X-Request-ID")
	if reqID == "" {
		t.Error("missing X-Request-ID header in response")
	}
}

func envOrDefault(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}
