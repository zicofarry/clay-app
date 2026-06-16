class MockEarningRepository {
  Future<Map<String, dynamic>> getTodayEarning() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {'total': 185000, 'orders': 7, 'hours': 4.5, 'tips': 15000};
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'date': '15 Jun', 'amount': 185000, 'orders': 7},
      {'date': '14 Jun', 'amount': 210000, 'orders': 9},
      {'date': '13 Jun', 'amount': 150000, 'orders': 5},
      {'date': '12 Jun', 'amount': 250000, 'orders': 11},
      {'date': '11 Jun', 'amount': 175000, 'orders': 6},
    ];
  }
}
