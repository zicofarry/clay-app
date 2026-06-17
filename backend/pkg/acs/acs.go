// Package acs provides a client for Azure Communication Services
// to send SMS messages and emails using the ACS REST API.
package acs

import (
	"bytes"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

type Config struct {
	Endpoint      string
	AccessKey     string
	SMSFromNumber string
	EmailFrom     string
}

func ConfigFromEnv() (*Config, bool) {
	connStr := os.Getenv("ACS_CONNECTION_STRING")
	if connStr == "" {
		return nil, false
	}

	endpoint, accessKey := parseConnectionString(connStr)
	if endpoint == "" || accessKey == "" {
		return nil, false
	}

	return &Config{
		Endpoint:      endpoint,
		AccessKey:     accessKey,
		SMSFromNumber: os.Getenv("ACS_SMS_FROM"),
		EmailFrom:     os.Getenv("ACS_EMAIL_FROM"),
	}, true
}

func parseConnectionString(s string) (endpoint, key string) {
	for _, part := range strings.Split(s, ";") {
		part = strings.TrimSpace(part)
		if strings.HasPrefix(part, "endpoint=") {
			endpoint = strings.TrimPrefix(part, "endpoint=")
		} else if strings.HasPrefix(part, "accesskey=") {
			key = strings.TrimPrefix(part, "accesskey=")
		}
	}
	return
}

type Client struct {
	config    Config
	httpClient *http.Client
}

func NewClient(cfg Config) *Client {
	return &Client{
		config:    cfg,
		httpClient: &http.Client{Timeout: 15 * time.Second},
	}
}

func (c *Client) SendSMS(to, message string) error {
	body := map[string]interface{}{
		"from": c.config.SMSFromNumber,
		"smsRecipients": []map[string]string{
			{"to": to},
		},
		"message": message,
		"smsSendOptions": map[string]bool{
			"enableDeliveryReport": false,
		},
	}

	path := "/sms?api-version=2021-03-07"
	return c.doRequest("POST", path, body)
}

type EmailAddress struct {
	Address     string `json:"address"`
	DisplayName string `json:"displayName,omitempty"`
}

type EmailContent struct {
	Subject   string `json:"subject"`
	PlainText string `json:"plainText,omitempty"`
	HTML      string `json:"html,omitempty"`
}

type EmailRecipients struct {
	To []EmailAddress `json:"to"`
}

type EmailBody struct {
	Sender      string          `json:"sender"`
	Recipients  EmailRecipients `json:"recipients"`
	Content     EmailContent    `json:"content"`
}

func (c *Client) SendEmail(to, subject, htmlContent string) error {
	body := EmailBody{
		Sender: c.config.EmailFrom,
		Recipients: EmailRecipients{
			To: []EmailAddress{{Address: to}},
		},
		Content: EmailContent{
			Subject:   subject,
			HTML:      htmlContent,
			PlainText: stripHTML(htmlContent),
		},
	}

	path := "/emails:send?api-version=2024-07-01-preview"
	return c.doRequest("POST", path, body)
}

func (c *Client) doRequest(method, path string, body interface{}) error {
	jsonBody, err := json.Marshal(body)
	if err != nil {
		return fmt.Errorf("marshal body: %w", err)
	}

	contentHash := sha256Hex(jsonBody)
	date := time.Now().UTC().Format(http.TimeFormat)

	parsedURL, err := url.Parse(c.config.Endpoint)
	if err != nil {
		return fmt.Errorf("parse endpoint: %w", err)
	}
	host := parsedURL.Host

	targetURL := strings.TrimRight(c.config.Endpoint, "/") + path

	req, err := http.NewRequest(method, targetURL, bytes.NewReader(jsonBody))
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-ms-date", date)
	req.Header.Set("x-ms-content-sha256", contentHash)
	req.Header.Set("Host", host)

	// Construct Azure HMAC String to Sign:
	// {HTTP_METHOD}\n{PATH_AND_QUERY}\n{TIMESTAMP};{HOST};{CONTENT_HASH}
	stringToSign := fmt.Sprintf("%s\n%s\n%s;%s;%s", method, path, date, host, contentHash)

	signature := computeHMAC(c.config.AccessKey, stringToSign)
	req.Header.Set("Authorization",
		fmt.Sprintf("HMAC-SHA256 SignedHeaders=x-ms-date;host;x-ms-content-sha256&Signature=%s", signature))

	resp, err := c.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("ACS request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode >= 400 {
		respBody, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("ACS error: status=%d body=%s", resp.StatusCode, string(respBody))
	}

	return nil
}

func sha256Hex(data []byte) string {
	h := sha256.Sum256(data)
	return base64.StdEncoding.EncodeToString(h[:])
}

func computeHMAC(accessKey, stringToSign string) string {
	key, err := base64.StdEncoding.DecodeString(accessKey)
	if err != nil {
		return ""
	}

	mac := hmac.New(sha256.New, key)
	mac.Write([]byte(stringToSign))
	return base64.StdEncoding.EncodeToString(mac.Sum(nil))
}

func stripHTML(html string) string {
	var buf strings.Builder
	inTag := false
	for _, r := range html {
		if r == '<' {
			inTag = true
			continue
		}
		if r == '>' {
			inTag = false
			continue
		}
		if !inTag {
			buf.WriteRune(r)
		}
	}
	return strings.TrimSpace(buf.String())
}
