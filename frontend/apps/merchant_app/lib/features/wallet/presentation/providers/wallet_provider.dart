import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/wallet_repository.dart';

// ── Repository Provider ────────────────────────────────────────────────────

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ClayApi.instance);
});

// ── State ──────────────────────────────────────────────────────────────────

class WalletState {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String? actionError;
  final int balance;
  final bool isActive;
  final String walletId;
  final List<Map<String, dynamic>> transactions;
  final int transactionsTotal;
  final int currentPage;
  final bool hasMore;
  final String? selectedTxType;

  const WalletState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.actionError,
    this.balance = 0,
    this.isActive = true,
    this.walletId = '',
    this.transactions = const [],
    this.transactionsTotal = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.selectedTxType,
  });

  WalletState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? actionError,
    int? balance,
    bool? isActive,
    String? walletId,
    List<Map<String, dynamic>>? transactions,
    int? transactionsTotal,
    int? currentPage,
    bool? hasMore,
    String? selectedTxType,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      balance: balance ?? this.balance,
      isActive: isActive ?? this.isActive,
      walletId: walletId ?? this.walletId,
      transactions: transactions ?? this.transactions,
      transactionsTotal: transactionsTotal ?? this.transactionsTotal,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedTxType: selectedTxType ?? this.selectedTxType,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repo;

  WalletNotifier(this._repo) : super(const WalletState());

  /// Load wallet balance + page 1 of transactions
  Future<void> loadWallet({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final walletData = await _repo.getWallet();
      state = state.copyWith(
        isLoading: false,
        balance: (walletData['balance'] as num?)?.toInt() ?? 0,
        isActive: walletData['is_active'] as bool? ?? true,
        walletId: walletData['wallet_id']?.toString() ?? '',
      );
      await loadTransactions(reset: true, silent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load (or reload) wallet transactions
  Future<void> loadTransactions({
    bool reset = false,
    bool silent = false,
    String? type,
  }) async {
    final page = reset ? 1 : state.currentPage + 1;
    final txType = type ?? state.selectedTxType;

    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final result = await _repo.getTransactions(
        page: page,
        limit: 20,
        type: txType,
      );

      final rawList = result['transactions'] as List? ?? [];
      final newTxs = rawList.map((t) => Map<String, dynamic>.from(t as Map)).toList();
      final total = (result['total'] as num?)?.toInt() ?? 0;

      final mergedTxs = reset ? newTxs : [...state.transactions, ...newTxs];

      state = state.copyWith(
        isLoading: false,
        transactions: mergedTxs,
        transactionsTotal: total,
        currentPage: page,
        hasMore: mergedTxs.length < total,
        selectedTxType: txType,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter transaksi berdasarkan tipe
  Future<void> filterByType(String? type) async {
    state = state.copyWith(selectedTxType: type);
    await loadTransactions(reset: true);
  }

  /// Load more (pagination)
  Future<void> loadMore() async {
    if (state.hasMore && !state.isLoading) {
      await loadTransactions(reset: false);
    }
  }

  /// POST /wallet/topup
  Future<Map<String, dynamic>?> topUp({
    required int amount,
    required String channel,
  }) async {
    state = state.copyWith(isActionLoading: true, clearActionError: true);
    try {
      final result = await _repo.topUp(amount: amount, channel: channel);
      state = state.copyWith(isActionLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, actionError: e.toString());
      return null;
    }
  }

  /// POST /wallet/transfer
  Future<Map<String, dynamic>?> transfer({
    required String recipientPhone,
    required int amount,
    String? notes,
  }) async {
    state = state.copyWith(isActionLoading: true, clearActionError: true);
    try {
      final result = await _repo.transfer(
        recipientPhone: recipientPhone,
        amount: amount,
        notes: notes,
      );
      // Refresh balance after transfer
      state = state.copyWith(
        isActionLoading: false,
        balance: (result['sender_balance_after'] as num?)?.toInt() ?? state.balance,
      );
      await loadTransactions(reset: true, silent: true);
      return result;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, actionError: e.toString());
      return null;
    }
  }

  /// GET /wallet/transactions/{txId}
  Future<Map<String, dynamic>?> getTransactionDetail(String txId) async {
    try {
      return await _repo.getTransactionDetail(txId);
    } catch (e) {
      return null;
    }
  }

  void clearActionError() {
    state = state.copyWith(clearActionError: true);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repo);
});
