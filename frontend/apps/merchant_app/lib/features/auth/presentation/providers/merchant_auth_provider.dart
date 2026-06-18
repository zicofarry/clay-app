import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/merchant_auth_repository.dart';

final merchantAuthProvider = StateNotifierProvider<MerchantAuthNotifier, MerchantAuthState>((ref) {
  return MerchantAuthNotifier(MerchantAuthRepository(ClayApi.instance));
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
  final MerchantAuthRepository _repo;
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

  void updateProfile(Map<String, dynamic> updatedData) {
    if (state.merchant != null) {
      final newMerchant = {...state.merchant!, ...updatedData};
      state = state.copyWith(merchant: newMerchant);
    }
  }

  void logout() {
    _repo.logout();
    state = const MerchantAuthState();
  }
}
