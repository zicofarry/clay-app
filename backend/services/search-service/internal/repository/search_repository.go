package repository

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/elastic/go-elasticsearch/v8"
	"github.com/elastic/go-elasticsearch/v8/esapi"
	"github.com/zicofarry/clay-app/backend/services/search-service/internal/model"
)

const (
	MerchantIndex = "merchants"
	MenuItemIndex = "menu_items"
)

type SearchRepositoryInterface interface {
	Ping(ctx context.Context) error
	InitIndices(ctx context.Context) error
	IndexMerchant(ctx context.Context, doc model.MerchantDocument) error
	IndexMenuItem(ctx context.Context, doc model.MenuItemDocument) error
	SearchMerchants(ctx context.Context, query string) ([]model.MerchantDocument, error)
	SearchMenuItems(ctx context.Context, query string) ([]model.MenuItemDocument, error)
}

type searchRepository struct {
	es *elasticsearch.Client
}

func NewSearchRepository(es *elasticsearch.Client) SearchRepositoryInterface {
	return &searchRepository{es: es}
}

func (r *searchRepository) Ping(ctx context.Context) error {
	if r.es == nil {
		return fmt.Errorf("elasticsearch client is nil")
	}
	res, err := r.es.Ping(r.es.Ping.WithContext(ctx))
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.IsError() {
		return fmt.Errorf("elasticsearch ping error: %s", res.Status())
	}
	return nil
}

func (r *searchRepository) InitIndices(ctx context.Context) error {
	merchantMapping := `{
		"mappings": {
			"properties": {
				"id": { "type": "keyword" },
				"name": { "type": "text" },
				"category": { "type": "keyword" },
				"location": { "type": "geo_point" },
				"rating": { "type": "float" },
				"tags": { "type": "keyword" },
				"is_active": { "type": "boolean" },
				"cuisine_types": { "type": "keyword" }
			}
		}
	}`

	menuItemMapping := `{
		"mappings": {
			"properties": {
				"id": { "type": "keyword" },
				"merchant_id": { "type": "keyword" },
				"merchant_name": { "type": "text" },
				"name": { "type": "text" },
				"description": { "type": "text" },
				"price": { "type": "float" },
				"tags": { "type": "keyword" },
				"cuisine_type": { "type": "keyword" },
				"is_available": { "type": "boolean" }
			}
		}
	}`

	indexes := map[string]string{
		MerchantIndex: merchantMapping,
		MenuItemIndex: menuItemMapping,
	}

	for idx, mapping := range indexes {
		req := esapi.IndicesCreateRequest{
			Index: idx,
			Body:  strings.NewReader(mapping),
		}
		res, err := req.Do(ctx, r.es)
		if err != nil {
			return err
		}
		defer res.Body.Close()
		// ignore "resource_already_exists_exception"
	}
	return nil
}

func (r *searchRepository) IndexMerchant(ctx context.Context, doc model.MerchantDocument) error {
	body, _ := json.Marshal(doc)
	req := esapi.IndexRequest{
		Index:      MerchantIndex,
		DocumentID: doc.ID,
		Body:       bytes.NewReader(body),
		Refresh:    "true",
	}
	res, err := req.Do(ctx, r.es)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.IsError() {
		return fmt.Errorf("error indexing merchant: %s", res.String())
	}
	return nil
}

func (r *searchRepository) IndexMenuItem(ctx context.Context, doc model.MenuItemDocument) error {
	body, _ := json.Marshal(doc)
	req := esapi.IndexRequest{
		Index:      MenuItemIndex,
		DocumentID: doc.ID,
		Body:       bytes.NewReader(body),
		Refresh:    "true",
	}
	res, err := req.Do(ctx, r.es)
	if err != nil {
		return err
	}
	defer res.Body.Close()
	if res.IsError() {
		return fmt.Errorf("error indexing menu item: %s", res.String())
	}
	return nil
}

func (r *searchRepository) SearchMerchants(ctx context.Context, query string) ([]model.MerchantDocument, error) {
	var buf bytes.Buffer
	var searchReq map[string]interface{}
	if query == "" {
		searchReq = map[string]interface{}{
			"query": map[string]interface{}{
				"match_all": map[string]interface{}{},
			},
		}
	} else {
		searchReq = map[string]interface{}{
			"query": map[string]interface{}{
				"multi_match": map[string]interface{}{
					"query":  query,
					"fields": []string{"name", "category", "tags", "cuisine_types"},
				},
			},
		}
	}
	if err := json.NewEncoder(&buf).Encode(searchReq); err != nil {
		return nil, err
	}

	res, err := r.es.Search(
		r.es.Search.WithContext(ctx),
		r.es.Search.WithIndex(MerchantIndex),
		r.es.Search.WithBody(&buf),
		r.es.Search.WithTrackTotalHits(true),
	)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	if res.IsError() {
		return nil, fmt.Errorf("search error: %s", res.Status())
	}

	var rMap map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&rMap); err != nil {
		return nil, err
	}

	hitsMap, ok := rMap["hits"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response structure: hits missing")
	}
	hitsList, ok := hitsMap["hits"].([]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response structure: inner hits missing")
	}

	var docs []model.MerchantDocument
	for _, hit := range hitsList {
		source := hit.(map[string]interface{})["_source"]
		sourceBytes, _ := json.Marshal(source)
		var doc model.MerchantDocument
		json.Unmarshal(sourceBytes, &doc)
		docs = append(docs, doc)
	}

	return docs, nil
}

func (r *searchRepository) SearchMenuItems(ctx context.Context, query string) ([]model.MenuItemDocument, error) {
	var buf bytes.Buffer
	var searchReq map[string]interface{}
	if query == "" {
		searchReq = map[string]interface{}{
			"query": map[string]interface{}{
				"match_all": map[string]interface{}{},
			},
		}
	} else {
		searchReq = map[string]interface{}{
			"query": map[string]interface{}{
				"multi_match": map[string]interface{}{
					"query":  query,
					"fields": []string{"name", "description", "tags"},
				},
			},
		}
	}
	if err := json.NewEncoder(&buf).Encode(searchReq); err != nil {
		return nil, err
	}

	res, err := r.es.Search(
		r.es.Search.WithContext(ctx),
		r.es.Search.WithIndex(MenuItemIndex),
		r.es.Search.WithBody(&buf),
		r.es.Search.WithTrackTotalHits(true),
	)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	if res.IsError() {
		return nil, fmt.Errorf("search error: %s", res.Status())
	}

	var rMap map[string]interface{}
	if err := json.NewDecoder(res.Body).Decode(&rMap); err != nil {
		return nil, err
	}

	hitsMap, ok := rMap["hits"].(map[string]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response structure: hits missing")
	}
	hitsList, ok := hitsMap["hits"].([]interface{})
	if !ok {
		return nil, fmt.Errorf("invalid response structure: inner hits missing")
	}

	var docs []model.MenuItemDocument
	for _, hit := range hitsList {
		source := hit.(map[string]interface{})["_source"]
		sourceBytes, _ := json.Marshal(source)
		var doc model.MenuItemDocument
		json.Unmarshal(sourceBytes, &doc)
		docs = append(docs, doc)
	}

	return docs, nil
}

