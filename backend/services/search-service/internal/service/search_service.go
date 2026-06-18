package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/zicofarry/clay-app/backend/services/search-service/internal/model"
	"github.com/zicofarry/clay-app/backend/services/search-service/internal/repository"
)

type SearchServiceInterface interface {
	CheckHealth(ctx context.Context) error
	
	// Search
	SearchMerchants(ctx context.Context, query map[string]string) (interface{}, error)
	SearchMenuItems(ctx context.Context, query map[string]string) (interface{}, error)
	GetTrending(ctx context.Context, query map[string]string) (interface{}, error)
	SearchSuggest(ctx context.Context, query map[string]string) (interface{}, error)
	GetPopular(ctx context.Context, query map[string]string) (interface{}, error)
	
	// Internal Index Management
	IndexMerchant(ctx context.Context, payload model.MerchantDocument) error
	DeleteMerchantIndex(ctx context.Context, merchantId string) error
	IndexMenuItem(ctx context.Context, payload model.MenuItemDocument) error
	DeleteMenuItemIndex(ctx context.Context, itemId string) error
	TriggerReindex(ctx context.Context, payload interface{}) error
}

type searchService struct {
	repo   repository.SearchRepositoryInterface
	logger *slog.Logger
}

func NewSearchService(repo repository.SearchRepositoryInterface, logger *slog.Logger) SearchServiceInterface {
	return &searchService{
		repo:   repo,
		logger: logger,
	}
}

func (s *searchService) CheckHealth(ctx context.Context) error {
	return s.repo.Ping(ctx)
}

func (s *searchService) SearchMerchants(ctx context.Context, query map[string]string) (interface{}, error) {
	q := query["q"]
	docs, err := s.repo.SearchMerchants(ctx, q)
	if err != nil {
		s.logger.Error("failed to search merchants", "error", err, "query", q)
		return nil, fmt.Errorf("search merchants failed: %w", err)
	}

	merchants := []map[string]interface{}{}
	for _, doc := range docs {
		// Map the ES document fields to match client-side names if needed
		merchants = append(merchants, map[string]interface{}{
			"id":               doc.ID,
			"name":             doc.Name,
			"category":         doc.Category,
			"rating":           doc.Rating,
			"distance_km":      0.5, // default or calculated
			"est_delivery_min": 15,  // default
			"logo_url":         "https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=3037&auto=format&fit=crop",
		})
	}

	return map[string]interface{}{
		"merchants": merchants,
	}, nil
}

func (s *searchService) SearchMenuItems(ctx context.Context, query map[string]string) (interface{}, error) {
	q := query["q"]
	docs, err := s.repo.SearchMenuItems(ctx, q)
	if err != nil {
		s.logger.Error("failed to search menu items", "error", err, "query", q)
		return nil, fmt.Errorf("search menu items failed: %w", err)
	}

	menuItems := []map[string]interface{}{}
	for _, doc := range docs {
		menuItems = append(menuItems, map[string]interface{}{
			"id":            doc.ID,
			"merchant_id":   doc.MerchantID,
			"merchant_name": doc.MerchantName,
			"name":          doc.Name,
			"description":   doc.Description,
			"price":         doc.Price,
			"tags":          doc.Tags,
			"cuisine_type":  doc.CuisineType,
			"is_available":  doc.IsAvailable,
		})
	}

	return map[string]interface{}{
		"menu_items": menuItems,
	}, nil
}
func (s *searchService) GetTrending(ctx context.Context, query map[string]string) (interface{}, error) { return nil, nil }
func (s *searchService) SearchSuggest(ctx context.Context, query map[string]string) (interface{}, error) { return nil, nil }
func (s *searchService) GetPopular(ctx context.Context, query map[string]string) (interface{}, error) { return nil, nil }

func (s *searchService) IndexMerchant(ctx context.Context, payload model.MerchantDocument) error { 
	if err := s.repo.IndexMerchant(ctx, payload); err != nil {
		s.logger.Error("failed to index merchant", "error", err, "id", payload.ID)
		return fmt.Errorf("indexing merchant failed: %w", err)
	}
	return nil 
}

func (s *searchService) DeleteMerchantIndex(ctx context.Context, merchantId string) error { return nil }

func (s *searchService) IndexMenuItem(ctx context.Context, payload model.MenuItemDocument) error { 
	if err := s.repo.IndexMenuItem(ctx, payload); err != nil {
		s.logger.Error("failed to index menu item", "error", err, "id", payload.ID)
		return fmt.Errorf("indexing menu item failed: %w", err)
	}
	return nil 
}

func (s *searchService) DeleteMenuItemIndex(ctx context.Context, itemId string) error { return nil }
func (s *searchService) TriggerReindex(ctx context.Context, payload interface{}) error { return nil }

