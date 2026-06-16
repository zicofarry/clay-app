import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_merchant_auth.dart';

final merchantAuthProvider = StateNotifierProvider<MerchantAuthNotifier, MerchantAuthState>((ref) {
  return MerchantAuthNotifier(MockMerchantAuthRepository());
});

class MerchantAuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? merchant;

  const MerchantAuthState({this.isLoading = false, this.error, this.merchant});

  MerchantAuthState copyWith({bool? isLoading, String? error, Map<String, dynamic>? merchant}) {
    return MerchantAuthState(isLoading: isLoading ?? this.isLoading, error: error, merchant: merchant ?? this.merchant);
  }
}

class MerchantAuthNotifier extends StateNotifier<MerchantAuthState> {
  final MockMerchantAuthRepository _repo;
  MerchantAuthNotifier(this._repo) : super(const MerchantAuthState());

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final merchant = await _repo.login(phone, password);
      state = state.copyWith(isLoading: false, merchant: merchant);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    state = const MerchantAuthState();
  }
}
