import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ClayApi.instance);
});

final walletStateProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.watch(walletRepositoryProvider));
});

class WalletState {
  final bool isLoading;
  final String? error;
  final int balance;
  final List<Map<String, dynamic>> transactions;

  const WalletState({
    this.isLoading = false,
    this.error,
    this.balance = 0,
    this.transactions = const [],
  });

  WalletState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? balance,
    List<Map<String, dynamic>>? transactions,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repo;

  WalletNotifier(this._repo) : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final wallet = await _repo.getWallet();
      state = state.copyWith(
        isLoading: false,
        balance: (wallet['balance'] as num).toInt(),
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> topUp(int amount) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.topUp(amount);
      await loadWallet();
      await loadTransactions();
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<bool> transfer({
    required String recipientPhone,
    required int amount,
    String note = '',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.transfer(
        recipientPhone: recipientPhone,
        amount: amount,
        note: note,
      );
      await loadWallet();
      await loadTransactions();
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<void> loadTransactions() async {
    try {
      final result = await _repo.getTransactions();
      final data = result['data'] as List? ?? [];
      state = state.copyWith(
        transactions: data.cast<Map<String, dynamic>>(),
      );
    } on AppException catch (_) {
      // silently fail — transactions are non-critical
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
