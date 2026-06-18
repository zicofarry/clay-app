import '../../../core/api_client.dart';
import '../../../core/api_endpoints.dart';

class Transaction {
  final String id;
  final String type;
  final String user;
  final String amount;
  final String status;
  final String date;

  Transaction({
    required this.id,
    required this.type,
    required this.user,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['transaction_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type'] ?? json['service_type'] ?? 'Transaction',
      user: json['user_name'] ?? json['user'] ?? json['user_id']?.toString() ?? '',
      amount: json['amount']?.toString() ?? json['total']?.toString() ?? '0',
      status: json['status'] ?? 'completed',
      date: json['created_at'] ?? json['date'] ?? '',
    );
  }
}

class TransactionsRepository {
  final AdminApiClient _client = AdminApiClient.instance;

  Future<List<Transaction>> getTransactions() async {
    final response = await _client.dio.get(ApiEndpoint.historyTransactions);
    final data = response.data;
    final List<dynamic> items = data['data'] is List ? data['data'] : [];
    return items.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }
}
