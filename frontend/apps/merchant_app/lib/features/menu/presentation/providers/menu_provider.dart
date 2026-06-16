import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_menu_repository.dart';

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  return MenuNotifier(MockMenuRepository());
});

class MenuState {
  final List<MenuItem> items;
  final bool isLoading;

  const MenuState({this.items = const [], this.isLoading = false});

  MenuState copyWith({List<MenuItem>? items, bool? isLoading}) {
    return MenuState(items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  final MockMenuRepository _repo;
  MenuNotifier(this._repo) : super(const MenuState());

  Future<void> loadMenu() async {
    state = state.copyWith(isLoading: true);
    final items = await _repo.getMenu();
    state = MenuState(items: items);
  }

  Future<void> addItem(MenuItem item) async {
    await _repo.addItem(item);
    await loadMenu();
  }

  Future<void> updateItem(MenuItem item) async {
    await _repo.updateItem(item);
    await loadMenu();
  }

  Future<void> toggleAvailability(String id) async {
    await _repo.toggleAvailability(id);
    await loadMenu();
  }

  Future<void> deleteItem(String id) async {
    await _repo.deleteItem(id);
    await loadMenu();
  }
}
