import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../data/mock_food_repository.dart';

final mockFoodRepoProvider = Provider<MockFoodRepository>((ref) => MockFoodRepository());

final foodStateProvider = StateNotifierProvider<FoodNotifier, FoodState>((ref) {
  return FoodNotifier(ref.watch(mockFoodRepoProvider));
});

class FoodState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> merchants;
  final List<Map<String, dynamic>> menuItems;
  final Map<String, int> cart;
  final Map<String, dynamic>? activeOrder;
  final List<Map<String, dynamic>> history;

  const FoodState({
    this.isLoading = false,
    this.error,
    this.merchants = const [],
    this.menuItems = const [],
    this.cart = const {},
    this.activeOrder,
    this.history = const [],
  });

  FoodState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? merchants,
    List<Map<String, dynamic>>? menuItems,
    Map<String, int>? cart,
    Map<String, dynamic>? activeOrder,
    List<Map<String, dynamic>>? history,
  }) {
    return FoodState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      merchants: merchants ?? this.merchants,
      menuItems: menuItems ?? this.menuItems,
      cart: cart ?? this.cart,
      activeOrder: activeOrder ?? this.activeOrder,
      history: history ?? this.history,
    );
  }
}

class FoodNotifier extends StateNotifier<FoodState> {
  final MockFoodRepository _repo;

  FoodNotifier(this._repo) : super(const FoodState());

  Future<void> loadMerchants() async {
    state = state.copyWith(isLoading: true);
    final list = await _repo.getMerchants();
    state = state.copyWith(isLoading: false, merchants: list);
  }

  Future<void> loadMenuItems(String merchantId) async {
    state = state.copyWith(isLoading: true);
    final items = await _repo.getMenuItems(merchantId);
    state = state.copyWith(isLoading: false, menuItems: items);
  }

  void addToCart(String itemId, int quantity) {
    final cart = Map<String, int>.from(state.cart);
    cart[itemId] = (cart[itemId] ?? 0) + quantity;
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
        orElse: () => {'price': 0},
      );
      total += (item['price'] as int) * entry.value;
    }
    return total;
  }

  Future<void> createOrder({
    required String merchantId, required String address,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = state.cart.entries.map((e) {
        final item = state.menuItems.firstWhere((i) => i['id'] == e.key);
        return {'item_id': e.key, 'name': item['name'], 'price': item['price'], 'qty': e.value};
      }).toList();

      final order = await _repo.createOrder(
        merchantId: merchantId,
        items: items,
        total: totalPrice,
        address: address,
      );
      state = state.copyWith(isLoading: false, activeOrder: order, cart: {});
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> loadHistory() async {
    final list = await _repo.getHistory();
    state = state.copyWith(history: list);
  }
}
