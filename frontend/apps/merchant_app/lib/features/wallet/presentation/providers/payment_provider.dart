import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/payment_repository.dart';

// ── Repository Provider ────────────────────────────────────────────────────

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ClayApi.instance);
});

// ── State ──────────────────────────────────────────────────────────────────

class PaymentState {
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String? actionError;
  final List<Map<String, dynamic>> paymentMethods;
  final String? defaultMethodId;
  final List<Map<String, dynamic>> transactions;
  final int transactionsTotal;
  final int currentPage;
  final bool hasMore;
  final String? selectedTxType;

  const PaymentState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.actionError,
    this.paymentMethods = const [],
    this.defaultMethodId,
    this.transactions = const [],
    this.transactionsTotal = 0,
    this.currentPage = 1,
    this.hasMore = false,
    this.selectedTxType,
  });

  PaymentState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? actionError,
    List<Map<String, dynamic>>? paymentMethods,
    String? defaultMethodId,
    List<Map<String, dynamic>>? transactions,
    int? transactionsTotal,
    int? currentPage,
    bool? hasMore,
    String? selectedTxType,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : (error ?? this.error),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
      paymentMethods: paymentMethods ?? this.paymentMethods,
      defaultMethodId: defaultMethodId ?? this.defaultMethodId,
      transactions: transactions ?? this.transactions,
      transactionsTotal: transactionsTotal ?? this.transactionsTotal,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedTxType: selectedTxType ?? this.selectedTxType,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repo;

  PaymentNotifier(this._repo) : super(const PaymentState());

  /// Load payment methods + first page of transaction history
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await Future.wait([
        _loadPaymentMethods(),
        _loadTransactions(page: 1, reset: true),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _loadPaymentMethods() async {
    final result = await _repo.getPaymentMethods();
    final rawMethods = result['methods'] as List? ?? [];
    final methods = rawMethods.map((m) => Map<String, dynamic>.from(m as Map)).toList();
    state = state.copyWith(
      paymentMethods: methods,
      defaultMethodId: result['default_method_id']?.toString(),
    );
  }

  Future<void> _loadTransactions({required int page, required bool reset, String? type}) async {
    final txType = type ?? state.selectedTxType;
    final result = await _repo.getTransactionHistory(
      page: page,
      limit: 20,
      type: txType,
    );
    final rawList = result['transactions'] as List? ?? [];
    final newTxs = rawList.map((t) => Map<String, dynamic>.from(t as Map)).toList();
    final total = (result['total'] as num?)?.toInt() ?? 0;
    final mergedTxs = reset ? newTxs : [...state.transactions, ...newTxs];
    state = state.copyWith(
      transactions: mergedTxs,
      transactionsTotal: total,
      currentPage: page,
      hasMore: mergedTxs.length < total,
      selectedTxType: txType,
    );
  }

  /// Reload payment methods only
  Future<void> reloadPaymentMethods() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _loadPaymentMethods();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more payment transactions (pagination)
  Future<void> loadMoreTransactions() async {
    if (!state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      await _loadTransactions(page: state.currentPage + 1, reset: false);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Filter payment transactions by type
  Future<void> filterByType(String? type) async {
    state = state.copyWith(isLoading: true, selectedTxType: type, clearError: true);
    try {
      await _loadTransactions(page: 1, reset: true, type: type);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// POST /payment-methods — Tambah metode pembayaran
  Future<bool> addPaymentMethod({required String type, bool setAsDefault = false}) async {
    state = state.copyWith(isActionLoading: true, clearActionError: true);
    try {
      await _repo.addPaymentMethod(type: type, setAsDefault: setAsDefault);
      await _loadPaymentMethods();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, actionError: e.toString());
      return false;
    }
  }

  /// DELETE /payment-methods/{methodId}
  Future<bool> deletePaymentMethod(String methodId) async {
    state = state.copyWith(isActionLoading: true, clearActionError: true);
    try {
      await _repo.deletePaymentMethod(methodId);
      await _loadPaymentMethods();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, actionError: e.toString());
      return false;
    }
  }

  /// POST /payment-methods/{methodId}/set-default
  Future<bool> setDefaultPaymentMethod(String methodId) async {
    state = state.copyWith(isActionLoading: true, clearActionError: true);
    try {
      await _repo.setDefaultPaymentMethod(methodId);
      await _loadPaymentMethods();
      state = state.copyWith(isActionLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isActionLoading: false, actionError: e.toString());
      return false;
    }
  }

  /// GET /transactions/{txId}
  Future<Map<String, dynamic>?> getTransactionDetail(String txId) async {
    try {
      return await _repo.getTransactionDetail(txId);
    } catch (_) {
      return null;
    }
  }

  void clearActionError() {
    state = state.copyWith(clearActionError: true);
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final repo = ref.watch(paymentRepositoryProvider);
  return PaymentNotifier(repo);
});
