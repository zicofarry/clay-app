class MockWalletRepository {
  Future<Map<String, dynamic>> getWallet() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'balance': 150000,
      'points': 250,
    };
  }

  Future<Map<String, dynamic>> topUp(int amount) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'success',
      'amount': amount,
      'new_balance': 150000 + amount,
    };
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'id': 'T001', 'type': 'topup', 'amount': 50000, 'date': '2026-06-15', 'desc': 'Top up via Bank BCA'},
      {'id': 'T002', 'type': 'payment', 'amount': -25000, 'date': '2026-06-15', 'desc': 'GoCar - Jl. Sudirman ke Thamrin'},
      {'id': 'T003', 'type': 'payment', 'amount': -30000, 'date': '2026-06-14', 'desc': 'GoFood - Bakso Merdeka'},
      {'id': 'T004', 'type': 'topup', 'amount': 100000, 'date': '2026-06-13', 'desc': 'Top up via GoPay'},
    ];
  }
}
