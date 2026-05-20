//go:build unit

package repository

import (
	"context"
	"database/sql"
	"testing"
	"time"

	"github.com/DATA-DOG/go-sqlmock"
)

func TestCreateCredential_Success(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening a stub database connection", err)
	}
	defer db.Close()

	repo := NewAuthRepository(db, nil)

	cred := &Credential{
		Email:          "test@example.com",
		Phone:          "+6281234567890",
		PasswordHash: "hashed_password",
		Role:           "user",
	}

	mock.ExpectQuery(`^INSERT INTO credentials`).
		WithArgs(cred.Email, cred.Phone, cred.PasswordHash, cred.Role).
		WillReturnRows(sqlmock.NewRows([]string{"id", "created_at", "updated_at"}).
			AddRow("uuid-123", time.Now(), time.Now()))

	created, err := repo.CreateCredential(context.Background(), cred)

	if err != nil {
		t.Errorf("error was not expected while inserting credential: %s", err)
	}

	if created.ID != "uuid-123" {
		t.Errorf("expected id 'uuid-123', got '%s'", created.ID)
	}

	if err := mock.ExpectationsWereMet(); err != nil {
		t.Errorf("there were unfulfilled expectations: %s", err)
	}
}

func TestFindByID_Found(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("failed to open mock db: %v", err)
	}
	defer db.Close()

	repo := NewAuthRepository(db, nil)

	mock.ExpectQuery(`^SELECT (.+) FROM credentials WHERE id = \$1$`).
		WithArgs("user-123").
		WillReturnRows(sqlmock.NewRows([]string{
			"id", "email", "phone", "password_hash", "role", "status", "email_verified", "phone_verified", "created_at", "updated_at",
		}).AddRow("user-123", "test@example.com", "+62812", "hash", "user", "active", false, true, time.Now(), time.Now()))

	cred, err := repo.FindByID(context.Background(), "user-123")

	if err != nil {
		t.Errorf("unexpected error: %v", err)
	}
	if cred == nil || cred.Email != "test@example.com" {
		t.Errorf("expected credential with email test@example.com")
	}
}

func TestFindByID_NotFound(t *testing.T) {
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("failed to open mock db: %v", err)
	}
	defer db.Close()

	repo := NewAuthRepository(db, nil)

	mock.ExpectQuery(`^SELECT (.+) FROM credentials WHERE id = \$1$`).
		WithArgs("unknown").
		WillReturnError(sql.ErrNoRows)

	_, err = repo.FindByID(context.Background(), "unknown")

	if err != sql.ErrNoRows {
		t.Errorf("expected sql.ErrNoRows, got %v", err)
	}
}
