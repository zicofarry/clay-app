import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../../data/repositories/merchant_profile_repository.dart';

final merchantProfileRepositoryProvider = Provider<MerchantProfileRepository>((ref) {
  return MerchantProfileRepository(ClayApi.instance);
});

class MerchantProfileState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> hours;
  final List<Map<String, dynamic>> banks;

  const MerchantProfileState({
    this.isLoading = false,
    this.error,
    this.hours = const [],
    this.banks = const [],
  });

  MerchantProfileState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? hours,
    List<Map<String, dynamic>>? banks,
  }) {
    return MerchantProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hours: hours ?? this.hours,
      banks: banks ?? this.banks,
    );
  }
}

class MerchantProfileNotifier extends StateNotifier<MerchantProfileState> {
  final MerchantProfileRepository _repo;
  final Ref _ref;

  MerchantProfileNotifier(this._repo, this._ref) : super(const MerchantProfileState());

  Future<void> loadProfileData(String merchantId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hours = await _repo.fetchOperatingHours(merchantId);
      final banks = await _repo.fetchBankAccounts(merchantId);
      state = state.copyWith(
        isLoading: false,
        hours: hours,
        banks: banks,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedMerchant = await _repo.updateProfile(data);
      // Update the auth provider state so other screens see the changes
      _ref.read(merchantAuthProvider.notifier).updateProfile(updatedMerchant);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String merchantId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedMerchant = await _repo.updateMerchantStatus(merchantId, status);
      _ref.read(merchantAuthProvider.notifier).updateProfile(updatedMerchant);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateOperatingHours(String merchantId, List<Map<String, dynamic>> hours) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedHours = await _repo.upsertOperatingHours(merchantId, hours);
      state = state.copyWith(isLoading: false, hours: updatedHours);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBankAccount(String merchantId, Map<String, dynamic> bank) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.addBankAccount(merchantId, bank);
      final updatedBanks = await _repo.fetchBankAccounts(merchantId);
      state = state.copyWith(isLoading: false, banks: updatedBanks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteBankAccount(String merchantId, String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteBankAccount(merchantId, accountId);
      final updatedBanks = await _repo.fetchBankAccounts(merchantId);
      state = state.copyWith(isLoading: false, banks: updatedBanks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setPrimaryBankAccount(String merchantId, String accountId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.setPrimaryBankAccount(merchantId, accountId);
      final updatedBanks = await _repo.fetchBankAccounts(merchantId);
      state = state.copyWith(isLoading: false, banks: updatedBanks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final merchantProfileProvider = StateNotifierProvider<MerchantProfileNotifier, MerchantProfileState>((ref) {
  final repo = ref.watch(merchantProfileRepositoryProvider);
  return MerchantProfileNotifier(repo, ref);
});
