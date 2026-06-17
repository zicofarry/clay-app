package service

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/google/uuid"
	"github.com/zicofarry/clay-app/backend/services/wallet-service/internal/repository"
)

type WalletService interface {
	GetBalance(ctx context.Context, userID uuid.UUID) (*repository.Wallet, error)
	TopUp(ctx context.Context, userID uuid.UUID, amount int64, channel string) (*repository.WalletTransaction, error)
	Transfer(ctx context.Context, senderID, receiverID uuid.UUID, amount int64, note string) (*repository.WalletTransaction, *repository.WalletTransaction, error)
	Debit(ctx context.Context, userID uuid.UUID, amount int64, refID uuid.UUID, desc string) (*repository.WalletTransaction, error)
	Credit(ctx context.Context, userID uuid.UUID, amount int64, refID uuid.UUID, txType, desc string) (*repository.WalletTransaction, error)
	GetTransactions(ctx context.Context, userID uuid.UUID, page, limit int) ([]repository.WalletTransaction, int, error)
}

type walletServiceImpl struct {
	repo   repository.WalletRepository
	logger *slog.Logger
}

func NewWalletService(repo repository.WalletRepository, logger *slog.Logger) WalletService {
	return &walletServiceImpl{repo: repo, logger: logger}
}

func (s *walletServiceImpl) GetBalance(ctx context.Context, userID uuid.UUID) (*repository.Wallet, error) {
	wallet, err := s.repo.GetWalletByUserID(ctx, userID)
	if err != nil {
		if err == repository.ErrWalletNotFound {
			// Auto create wallet for user if not exists
			return s.repo.CreateWallet(ctx, userID)
		}
		s.logger.Error("failed to get wallet", slog.Any("error", err), slog.String("user_id", userID.String()))
		return nil, err
	}
	return wallet, nil
}

func (s *walletServiceImpl) TopUp(ctx context.Context, userID uuid.UUID, amount int64, channel string) (*repository.WalletTransaction, error) {
	// For simplicity, we directly credit. In real scenario, topup creates pending tx and returns gateway URL.
	// We'll mimic the "callback" processing by directly crediting.
	tx, err := s.repo.CreditWallet(ctx, userID, amount, "top_up", "Top up via "+channel, uuid.New())
	if err != nil {
		if err == repository.ErrWalletNotFound {
			_, errCreate := s.repo.CreateWallet(ctx, userID)
			if errCreate != nil {
				return nil, errCreate
			}
			return s.repo.CreditWallet(ctx, userID, amount, "top_up", "Top up via "+channel, uuid.New())
		}
		s.logger.Error("failed to credit wallet on topup", slog.Any("error", err))
		return nil, err
	}
	return tx, nil
}

func (s *walletServiceImpl) Debit(ctx context.Context, userID uuid.UUID, amount int64, refID uuid.UUID, desc string) (*repository.WalletTransaction, error) {
	tx, err := s.repo.DebitWallet(ctx, userID, amount, "debit", desc, refID)
	if err != nil {
		s.logger.Error("failed to debit wallet", slog.Any("error", err), slog.String("user_id", userID.String()))
		return nil, err
	}
	return tx, nil
}

func (s *walletServiceImpl) Credit(ctx context.Context, userID uuid.UUID, amount int64, refID uuid.UUID, txType, desc string) (*repository.WalletTransaction, error) {
	tx, err := s.repo.CreditWallet(ctx, userID, amount, txType, desc, refID)
	if err != nil {
		s.logger.Error("failed to credit wallet", slog.Any("error", err), slog.String("user_id", userID.String()))
		return nil, err
	}
	return tx, nil
}

func (s *walletServiceImpl) Transfer(ctx context.Context, senderID, receiverID uuid.UUID, amount int64, note string) (*repository.WalletTransaction, *repository.WalletTransaction, error) {
	if senderID == receiverID {
		return nil, nil, fmt.Errorf("cannot transfer to yourself")
	}

	refID := uuid.New()
	desc := note
	if desc == "" {
		desc = "Transfer"
	}

	senderTx, err := s.repo.DebitWallet(ctx, senderID, amount, "transfer", desc, refID)
	if err != nil {
		s.logger.Error("failed to debit sender", slog.Any("error", err), slog.String("sender_id", senderID.String()))
		return nil, nil, err
	}

	receiverTx, err := s.repo.CreditWallet(ctx, receiverID, amount, "transfer", desc, refID)
	if err != nil {
		// Rollback: credit sender back
		_, rollbackErr := s.repo.CreditWallet(ctx, senderID, amount, "transfer_rollback", "Rollback: "+desc, refID)
		if rollbackErr != nil {
			s.logger.Error("CRITICAL: failed to rollback sender debit", slog.Any("error", rollbackErr))
		}
		s.logger.Error("failed to credit receiver", slog.Any("error", err), slog.String("receiver_id", receiverID.String()))
		return nil, nil, err
	}

	return senderTx, receiverTx, nil
}

func (s *walletServiceImpl) GetTransactions(ctx context.Context, userID uuid.UUID, page, limit int) ([]repository.WalletTransaction, int, error) {
	txs, total, err := s.repo.GetTransactionsByUserID(ctx, userID, page, limit)
	if err != nil {
		s.logger.Error("failed to get transactions", slog.Any("error", err), slog.String("user_id", userID.String()))
		return nil, 0, err
	}
	return txs, total, nil
}
