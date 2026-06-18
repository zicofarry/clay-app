import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clay_shared/clay_shared.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../../data/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return MenuRepository(ClayApi.instance);
});

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final repo = ref.watch(menuRepositoryProvider);
  return MenuNotifier(repo, ref);
});

class MenuState {
  final List<MenuItem> items;
  final bool isLoading;
  final String? error;

  const MenuState({this.items = const [], this.isLoading = false, this.error});

  MenuState copyWith({List<MenuItem>? items, bool? isLoading, String? error}) {
    return MenuState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRepository _repo;
  final Ref _ref;

  MenuNotifier(this._repo, this._ref) : super(const MenuState());

  Future<void> loadMenu() async {
    final merchant = _ref.read(merchantAuthProvider).merchant;
    if (merchant == null || merchant['id'] == null) return;
    final merchantId = merchant['id'] as String;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repo.fetchCategories(merchantId);
      final items = await _repo.fetchMenuItems(merchantId, categories);
      state = MenuState(items: items, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addItem(MenuItem item) async {
    final merchant = _ref.read(merchantAuthProvider).merchant;
    if (merchant == null || merchant['id'] == null) return;
    final merchantId = merchant['id'] as String;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final categoryId = await _resolveOrCreateCategoryId(merchantId, item.category);
      await _repo.createMenuItem(merchantId, categoryId, item.name, item.price);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateItem(MenuItem item) async {
    final merchant = _ref.read(merchantAuthProvider).merchant;
    if (merchant == null || merchant['id'] == null) return;
    final merchantId = merchant['id'] as String;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final categoryId = await _resolveOrCreateCategoryId(merchantId, item.category);
      await _repo.updateMenuItem(merchantId, item.id, categoryId, item.name, item.price);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleAvailability(String id) async {
    final merchant = _ref.read(merchantAuthProvider).merchant;
    if (merchant == null || merchant['id'] == null) return;
    final merchantId = merchant['id'] as String;

    final item = state.items.firstWhere((i) => i.id == id);
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.toggleAvailability(merchantId, id, !item.available);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteItem(String id) async {
    final merchant = _ref.read(merchantAuthProvider).merchant;
    if (merchant == null || merchant['id'] == null) return;
    final merchantId = merchant['id'] as String;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repo.deleteMenuItem(merchantId, id);
      await loadMenu();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> _resolveOrCreateCategoryId(String merchantId, String categoryName) async {
    final categories = await _repo.fetchCategories(merchantId);
    
    final match = categories.firstWhere(
      (cat) => cat.name.trim().toLowerCase() == categoryName.trim().toLowerCase(),
      orElse: () => MenuCategory(id: '', merchantId: '', name: '', displayOrder: 0),
    );

    if (match.id.isNotEmpty) {
      return match.id;
    }

    final newCat = await _repo.createCategory(
      merchantId, 
      categoryName.trim(), 
      categories.length + 1,
    );
    return newCat.id;
  }
}
