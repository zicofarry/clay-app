import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../providers/wallet_provider.dart';
import '../providers/payment_provider.dart';

class WalletDashboardScreen extends ConsumerStatefulWidget {
  const WalletDashboardScreen({super.key});

  @override
  ConsumerState<WalletDashboardScreen> createState() => _WalletDashboardScreenState();
}

class _WalletDashboardScreenState extends ConsumerState<WalletDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(walletProvider.notifier).loadWallet();
      ref.read(paymentProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(num value) {
    if (value >= 1000000000) {
      return 'Rp ${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value >= 1000000) {
      return 'Rp ${(value / 1000000).toStringAsFixed(1)}jt';
    } else {
      final valueStr = value.toInt().toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = valueStr.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) buffer.write('.');
        buffer.write(valueStr[i]);
        count++;
      }
      return 'Rp ${buffer.toString().split('').reversed.join('')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: ClayColors.background,
      body: RefreshIndicator(
        color: ClayColors.primary,
        onRefresh: () async {
          await ref.read(walletProvider.notifier).loadWallet();
          await ref.read(paymentProvider.notifier).loadAll();
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: ClayColors.primaryDark,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.credit_card, color: Colors.white),
                  tooltip: 'Metode Pembayaran',
                  onPressed: () => context.push('/wallet/payment-methods'),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _WalletHeaderCard(
                  balance: walletState.balance,
                  isActive: walletState.isActive,
                  isLoading: walletState.isLoading,
                  formatCurrency: _formatCurrency,
                  onTopUp: () => context.push('/wallet/topup'),
                  onTransfer: () => context.push('/wallet/transfer'),
                ),
              ),
              title: innerBoxIsScrolled
                  ? Text(
                      _formatCurrency(walletState.balance),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: ClayColors.primary,
                  unselectedLabelColor: ClayColors.textSecondary,
                  indicatorColor: ClayColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Transaksi Wallet'),
                    Tab(text: 'Riwayat Pembayaran'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _WalletTransactionsTab(formatCurrency: _formatCurrency),
              _PaymentTransactionsTab(formatCurrency: _formatCurrency),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header Card ────────────────────────────────────────────────────────────

class _WalletHeaderCard extends StatelessWidget {
  final int balance;
  final bool isActive;
  final bool isLoading;
  final String Function(num) formatCurrency;
  final VoidCallback onTopUp;
  final VoidCallback onTransfer;

  const _WalletHeaderCard({
    required this.balance,
    required this.isActive,
    required this.isLoading,
    required this.formatCurrency,
    required this.onTopUp,
    required this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF6FA7E6), Color(0xFF97C5F5)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 12,
                          color: isActive ? Colors.greenAccent : Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? 'Aktif' : 'Non-aktif',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
                  const SizedBox(width: 6),
                  const Text('Clay Wallet', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Saldo Anda',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              isLoading
                  ? const SizedBox(
                      height: 38,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      ),
                    )
                  : Text(
                      formatCurrency(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Top Up',
                      onTap: onTopUp,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.send_outlined,
                      label: 'Transfer',
                      onTap: onTransfer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Tab 1: Wallet Transactions ─────────────────────────────────────────────

class _WalletTransactionsTab extends ConsumerWidget {
  final String Function(num) formatCurrency;

  const _WalletTransactionsTab({required this.formatCurrency});

  static const _txTypes = [
    {'label': 'Semua', 'value': ''},
    {'label': 'Top Up', 'value': 'top_up'},
    {'label': 'Debit', 'value': 'debit'},
    {'label': 'Kredit', 'value': 'credit'},
    {'label': 'Refund', 'value': 'refund'},
    {'label': 'Cashback', 'value': 'cashback'},
    {'label': 'Transfer Masuk', 'value': 'transfer_in'},
    {'label': 'Transfer Keluar', 'value': 'transfer_out'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);
    final selectedType = state.selectedTxType ?? '';

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _txTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = _txTypes[i];
              final isSelected = selectedType == t['value'];
              return FilterChip(
                label: Text(t['label']!),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(walletProvider.notifier).filterByType(
                        t['value']!.isEmpty ? null : t['value'],
                      );
                },
                selectedColor: ClayColors.primary.withValues(alpha: 0.2),
                checkmarkColor: ClayColors.primaryDark,
                labelStyle: TextStyle(
                  color: isSelected ? ClayColors.primaryDark : ClayColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: ClayColors.muted,
                side: BorderSide(
                  color: isSelected ? ClayColors.primary : Colors.transparent,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
        // Transactions list
        Expanded(
          child: state.isLoading && state.transactions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.error != null && state.transactions.isEmpty
                  ? _ErrorView(
                      message: state.error!,
                      onRetry: () => ref.read(walletProvider.notifier).loadWallet(),
                    )
                  : state.transactions.isEmpty
                      ? const _EmptyView(message: 'Belum ada transaksi wallet')
                      : NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n is ScrollEndNotification && n.metrics.extentAfter < 100) {
                              ref.read(walletProvider.notifier).loadMore();
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              if (i >= state.transactions.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final tx = state.transactions[i];
                              return _WalletTxCard(tx: tx, formatCurrency: formatCurrency);
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _WalletTxCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  final String Function(num) formatCurrency;

  const _WalletTxCard({required this.tx, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    final type = tx['type']?.toString() ?? '';
    final amount = (tx['amount'] as num?) ?? 0;
    final isCredit = amount > 0;
    final description = tx['description']?.toString() ?? _typeLabel(type);
    final dateStr = tx['created_at']?.toString() ?? '';
    final formattedDate = _formatDate(dateStr);
    final balanceAfter = (tx['balance_after'] as num?);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ClayColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCredit
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _typeIcon(type),
            color: isCredit ? Colors.green : Colors.orange,
            size: 22,
          ),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(formattedDate, style: const TextStyle(color: ClayColors.textSecondary, fontSize: 12)),
            if (balanceAfter != null)
              Text(
                'Saldo: ${formatCurrency(balanceAfter)}',
                style: const TextStyle(color: ClayColors.textSecondary, fontSize: 11),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : ''}${formatCurrency(amount.abs())}',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _typeBadgeColor(type).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _typeLabel(type),
                style: TextStyle(
                  color: _typeBadgeColor(type),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    const labels = {
      'top_up': 'Top Up',
      'debit': 'Debit',
      'credit': 'Kredit',
      'refund': 'Refund',
      'cashback': 'Cashback',
      'transfer_in': 'Transfer Masuk',
      'transfer_out': 'Transfer Keluar',
      'settlement': 'Settlement',
    };
    return labels[type] ?? type;
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'top_up':
        return Icons.add_circle_outline;
      case 'transfer_in':
        return Icons.call_received;
      case 'transfer_out':
        return Icons.call_made;
      case 'refund':
        return Icons.undo;
      case 'cashback':
        return Icons.redeem;
      case 'settlement':
        return Icons.handshake_outlined;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _typeBadgeColor(String type) {
    switch (type) {
      case 'top_up':
      case 'credit':
      case 'transfer_in':
      case 'refund':
      case 'cashback':
      case 'settlement':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = _monthName(dt.month);
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day $month ${dt.year}, $hour:$min';
    } catch (_) {
      return dateStr;
    }
  }

  String _monthName(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[m - 1];
  }
}

// ── Tab 2: Payment Transactions ────────────────────────────────────────────

class _PaymentTransactionsTab extends ConsumerWidget {
  final String Function(num) formatCurrency;

  const _PaymentTransactionsTab({required this.formatCurrency});

  static const _txTypes = [
    {'label': 'Semua', 'value': ''},
    {'label': 'Charge', 'value': 'charge'},
    {'label': 'Refund', 'value': 'refund'},
    {'label': 'Top Up', 'value': 'top_up'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentProvider);
    final selectedType = state.selectedTxType ?? '';

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _txTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final t = _txTypes[i];
              final isSelected = selectedType == t['value'];
              return FilterChip(
                label: Text(t['label']!),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(paymentProvider.notifier).filterByType(
                        t['value']!.isEmpty ? null : t['value'],
                      );
                },
                selectedColor: ClayColors.purple.withValues(alpha: 0.15),
                checkmarkColor: ClayColors.purple,
                labelStyle: TextStyle(
                  color: isSelected ? ClayColors.purple : ClayColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                backgroundColor: ClayColors.muted,
                side: BorderSide(color: isSelected ? ClayColors.purple : Colors.transparent),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              );
            },
          ),
        ),
        Expanded(
          child: state.isLoading && state.transactions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.error != null && state.transactions.isEmpty
                  ? _ErrorView(
                      message: state.error!,
                      onRetry: () => ref.read(paymentProvider.notifier).loadAll(),
                    )
                  : state.transactions.isEmpty
                      ? const _EmptyView(message: 'Belum ada riwayat pembayaran')
                      : NotificationListener<ScrollNotification>(
                          onNotification: (n) {
                            if (n is ScrollEndNotification && n.metrics.extentAfter < 100) {
                              ref.read(paymentProvider.notifier).loadMoreTransactions();
                            }
                            return false;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
                            separatorBuilder: (_, _) => const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              if (i >= state.transactions.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _PaymentTxCard(
                                tx: state.transactions[i],
                                formatCurrency: formatCurrency,
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

class _PaymentTxCard extends StatelessWidget {
  final Map<String, dynamic> tx;
  final String Function(num) formatCurrency;

  const _PaymentTxCard({required this.tx, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    final type = tx['type']?.toString() ?? '';
    final status = tx['status']?.toString() ?? '';
    final amount = (tx['amount'] as num?) ?? 0;
    final description = tx['description']?.toString() ?? _typeLabel(type);
    final methodType = tx['payment_method_type']?.toString() ?? '';
    final dateStr = tx['created_at']?.toString() ?? '';

    Color statusColor;
    switch (status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      case 'refunded':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ClayColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: ClayColors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_methodIcon(methodType), color: ClayColors.purple, size: 22),
        ),
        title: Text(
          description,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              _formatDate(dateStr),
              style: const TextStyle(color: ClayColors.textSecondary, fontSize: 12),
            ),
            if (methodType.isNotEmpty)
              Text(
                _methodLabel(methodType),
                style: const TextStyle(color: ClayColors.textSecondary, fontSize: 11),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    const map = {'charge': 'Pembayaran', 'refund': 'Refund', 'top_up': 'Top Up'};
    return map[type] ?? type;
  }

  String _statusLabel(String status) {
    const map = {
      'completed': 'Selesai',
      'failed': 'Gagal',
      'refunded': 'Direfund',
      'pending': 'Pending',
    };
    return map[status] ?? status;
  }

  String _methodLabel(String method) {
    const map = {
      'clay_wallet': 'Clay Wallet',
      'credit_card': 'Kartu Kredit',
      'debit_card': 'Kartu Debit',
      'bank_transfer': 'Transfer Bank',
      'gopay': 'GoPay',
      'ovo': 'OVO',
      'dana': 'DANA',
      'cod': 'COD',
    };
    return map[method] ?? method;
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'clay_wallet':
        return Icons.account_balance_wallet_outlined;
      case 'credit_card':
      case 'debit_card':
        return Icons.credit_card;
      case 'gopay':
      case 'ovo':
      case 'dana':
        return Icons.phone_android;
      case 'bank_transfer':
        return Icons.account_balance_outlined;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$day/${dt.month.toString().padLeft(2, '0')}/${dt.year} $hour:$min';
    } catch (_) {
      return dateStr;
    }
  }
}

// ── Shared Widgets ─────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: ClayColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Bar SliverPersistentHeaderDelegate ─────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => tabBar != oldDelegate.tabBar;
}
