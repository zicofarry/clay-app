import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../auth/presentation/providers/driver_auth_provider.dart';
import '../../order/presentation/providers/order_provider.dart';

final _isOnlineProvider = StateProvider<bool>((ref) => false);

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(orderProvider.notifier).loadIncoming());
  }

  @override
  Widget build(BuildContext context) {
    final driver = ref.watch(driverAuthProvider).driver;
    final isOnline = ref.watch(_isOnlineProvider);
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${driver?['name'] ?? 'Driver'}'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => context.go('/earning')),
          IconButton(icon: const Icon(Icons.person), onPressed: () => context.go('/profile')),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: ClayColors.primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isOnline ? 'Kamu Online' : 'Kamu Offline', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(isOnline ? 'Siap menerima pesanan' : 'Aktifkan untuk mulai', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: isOnline,
                  activeColor: Colors.green,
                  onChanged: (v) {
                    ref.read(_isOnlineProvider.notifier).state = v;
                    if (v) ref.read(orderProvider.notifier).loadIncoming();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isOnline
                ? (orderState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : orderState.incoming.isEmpty
                        ? const Center(child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Menunggu pesanan...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orderState.incoming.length,
                            itemBuilder: (_, i) {
                              final o = orderState.incoming[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Icon(o['type'] == 'GoFood' ? Icons.restaurant : Icons.directions_car, color: ClayColors.primary),
                                        const SizedBox(width: 8),
                                        Text(o['type'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const Spacer(),
                                        Text('Rp ${o['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                                      ]),
                                      const Divider(),
                                      _Row(Icons.location_on, o['pickup']),
                                      _Row(Icons.flag, o['dest']),
                                      if (o['merchant'] != null) _Row(Icons.store, o['merchant']),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Text('${o['distance']} • ${o['eta']}', style: const TextStyle(color: Colors.grey)),
                                      ]),
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        Expanded(child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                          onPressed: () => context.go('/order/${o['id']}'),
                                          child: const Text('Terima'),
                                        )),
                                        const SizedBox(width: 12),
                                        Expanded(child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                          onPressed: () => ref.read(orderProvider.notifier).rejectOrder(o['id']),
                                          child: const Text('Tolak'),
                                        )),
                                      ]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ))
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_off, size: 64, color: ClayColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Aktifkan mode online', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Untuk mulai menerima pesanan', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
          ),
          if (orderState.activeOrder != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Pesanan aktif: ${orderState.activeOrder!['id']}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  TextButton(onPressed: () => context.go('/order/${orderState.activeOrder!['id']}'), child: const Text('Lihat')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
