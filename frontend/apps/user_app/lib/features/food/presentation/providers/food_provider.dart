import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/food_repository.dart';

final foodRepositoryProvider = Provider<FoodRepository>((ref) => FoodRepository());

final foodStateProvider = StateNotifierProvider<FoodNotifier, FoodState>((ref) {
  return FoodNotifier(ref.watch(foodRepositoryProvider));
});

class FoodState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> merchants;
  final List<Map<String, dynamic>> menuItems;
  final Map<String, int> cart;
  final Map<String, dynamic>? activeOrder;
  final List<Map<String, dynamic>> history;
  final String? selectedMerchantId;
  final String? selectedMerchantName;
  final String? selectedAddress;
  final String? selectedAddressLabel;

  const FoodState({
    this.isLoading = false,
    this.error,
    this.merchants = const [],
    this.menuItems = const [],
    this.cart = const {},
    this.activeOrder,
    this.history = const [],
    this.selectedMerchantId,
    this.selectedMerchantName,
    this.selectedAddress,
    this.selectedAddressLabel,
  });

  FoodState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? merchants,
    List<Map<String, dynamic>>? menuItems,
    Map<String, int>? cart,
    Map<String, dynamic>? activeOrder,
    List<Map<String, dynamic>>? history,
    String? selectedMerchantId,
    String? selectedMerchantName,
    String? selectedAddress,
    String? selectedAddressLabel,
  }) {
    return FoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      merchants: merchants ?? this.merchants,
      menuItems: menuItems ?? this.menuItems,
      cart: cart ?? this.cart,
      activeOrder: activeOrder ?? this.activeOrder,
      history: history ?? this.history,
      selectedMerchantId: selectedMerchantId ?? this.selectedMerchantId,
      selectedMerchantName: selectedMerchantName ?? this.selectedMerchantName,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedAddressLabel: selectedAddressLabel ?? this.selectedAddressLabel,
    );
  }
}

class FoodNotifier extends StateNotifier<FoodState> {
  final FoodRepository _repo;

  FoodNotifier(this._repo) : super(const FoodState());

  void setSelectedAddress(String address, String label) {
    state = state.copyWith(
      selectedAddress: address,
      selectedAddressLabel: label,
    );
  }

  void selectMerchant(String merchantId, String merchantName) {
    if (state.selectedMerchantId != merchantId) {
      state = state.copyWith(
        selectedMerchantId: merchantId,
        selectedMerchantName: merchantName,
        cart: {},
      );
    } else {
      state = state.copyWith(
        selectedMerchantId: merchantId,
        selectedMerchantName: merchantName,
      );
    }
  }

  Future<void> loadMerchants() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getMerchants();
      state = state.copyWith(isLoading: false, merchants: list);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMenuItems(String merchantId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.getMenuItems(merchantId);
      state = state.copyWith(isLoading: false, menuItems: items);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void addToCart(String itemId, int quantity) {
    final cart = Map<String, int>.from(state.cart);
    final current = cart[itemId] ?? 0;
    final updated = current + quantity;
    if (updated <= 0) {
      cart.remove(itemId);
    } else {
      cart[itemId] = updated;
    }
    state = state.copyWith(cart: cart);
  }

  void updateCartQuantity(String itemId, int quantity) {
    final cart = Map<String, int>.from(state.cart);
    if (quantity <= 0) {
      cart.remove(itemId);
    } else {
      cart[itemId] = quantity;
    }
    state = state.copyWith(cart: cart);
  }

  void removeFromCart(String itemId) {
    final cart = Map<String, int>.from(state.cart);
    cart.remove(itemId);
    state = state.copyWith(cart: cart);
  }

  void clearCart() {
    state = state.copyWith(cart: {});
  }

  int get totalItems => state.cart.values.fold(0, (a, b) => a + b);

  int get totalPrice {
    int total = 0;
    for (final entry in state.cart.entries) {
      final item = state.menuItems.firstWhere(
        (i) => i['id'] == entry.key,
        orElse: () => <String, dynamic>{'price': 0},
      );
      total += (item['price'] as int) * entry.value;
    }
    return total;
  }

  Future<void> createOrder({
    required String merchantId, required String address, String paymentMethod = 'cash',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = state.cart.entries.map((e) {
        final item = state.menuItems.firstWhere((i) => i['id'] == e.key);
        return {'item_id': e.key, 'name': item['name'], 'price': item['price'], 'qty': e.value};
      }).toList();

      final targetMerchantId = merchantId.isNotEmpty ? merchantId : (state.selectedMerchantId ?? '');
      final order = await _repo.createOrder(
        merchantId: targetMerchantId,
        items: items,
        total: totalPrice,
        address: address,
        paymentMethod: paymentMethod,
      );
      state = state.copyWith(isLoading: false, activeOrder: order, cart: {});
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadActiveOrder() async {
    try {
      final order = await _repo.getActiveOrder();
      state = state.copyWith(activeOrder: order);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadHistory() async {
    try {
      final list = await _repo.getHistory();
      state = state.copyWith(history: list);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> reorder(String orderId, String merchantId, String merchantName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final details = await _repo.getOrderDetails(orderId);
      if (details != null) {
        selectMerchant(merchantId, merchantName);
        clearCart();
        
        final items = details['items'] as List?;
        if (items != null) {
          for (final item in items) {
            final itemId = item['menu_item_id']?.toString() ?? item['id']?.toString() ?? '';
            final qty = item['quantity'] as int? ?? 1;
            if (itemId.isNotEmpty) {
              addToCart(itemId, qty);
            }
          }
        }
        state = state.copyWith(isLoading: false);
        return true;
      }
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<bool> submitRating({
    required String orderId,
    required int driverRating,
    required int merchantRating,
    required String comment,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.submitRating(orderId, driverRating, merchantRating, comment);
      state = state.copyWith(isLoading: false);
      return true;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    state = state.copyWith(isLoading: false);
    return false;
  }
}
