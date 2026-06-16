class MenuItem {
  final String id, name, category;
  final int price;
  final bool available;

  MenuItem({required this.id, required this.name, required this.category, required this.price, this.available = true});
}

class MockMenuRepository {
  List<MenuItem> _items = [
    MenuItem(id: 'M-001', name: 'Bakso Besar', category: 'Bakso', price: 25000),
    MenuItem(id: 'M-002', name: 'Bakso Kecil', category: 'Bakso', price: 18000),
    MenuItem(id: 'M-003', name: 'Mie Ayam', category: 'Mie', price: 20000),
    MenuItem(id: 'M-004', name: 'Es Teh', category: 'Minuman', price: 5000),
    MenuItem(id: 'M-005', name: 'Es Jeruk', category: 'Minuman', price: 7000),
    MenuItem(id: 'M-006', name: 'Pangsit Goreng', category: 'Snack', price: 12000),
  ];

  Future<List<MenuItem>> getMenu() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_items);
  }

  Future<void> addItem(MenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _items.add(item);
  }

  Future<void> updateItem(MenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx != -1) _items[idx] = item;
  }

  Future<void> toggleAvailability(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) _items[idx] = MenuItem(id: _items[idx].id, name: _items[idx].name, category: _items[idx].category, price: _items[idx].price, available: !_items[idx].available);
  }

  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((i) => i.id == id);
  }
}
