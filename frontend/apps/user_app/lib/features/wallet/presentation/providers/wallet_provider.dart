import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/mock_wallet_repository.dart';

final mockWalletRepoProvider = Provider<MockWalletRepository>((ref) => MockWalletRepository());

final walletStateProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(ref.watch(mockWalletRepoProvider));
});

class WalletState {
  final bool isLoading;
  final String? error;
  final int balance;
  final int points;
  final List<Map<String, dynamic>> transactions;

  const WalletState({
    this.isLoading = false,
    this.error,
    this.balance = 0,
    this.points = 0,
    this.transactions = const [],
  });

  WalletState copyWith({
    bool? isLoading,
    String? error,
    int? balance,
    int? points,
    List<Map<String, dynamic>>? transactions,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      balance: balance ?? this.balance,
      points: points ?? this.points,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final MockWalletRepository _repo;

  WalletNotifier(this._repo) : super(const WalletState());

  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true);
    final wallet = await _repo.getWallet();
    state = state.copyWith(
      isLoading: false,
      balance: wallet['balance'] as int,
      points: wallet['points'] as int,
    );
  }

  Future<void> topUp(int amount) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repo.topUp(amount);
      state = state.copyWith(isLoading: false, balance: result['new_balance'] as int);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadTransactions() async {
    final list = await _repo.getTransactions();
    state = state.copyWith(transactions: list);
  }
}
