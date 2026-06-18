import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clay_ui/clay_ui.dart';
import '../../../auth/presentation/providers/merchant_auth_provider.dart';
import '../providers/merchant_profile_provider.dart';

class MerchantProfileScreen extends ConsumerStatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  ConsumerState<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends ConsumerState<MerchantProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final m = ref.read(merchantAuthProvider).merchant;
      if (m != null && m['id'] != null) {
        ref.read(merchantProfileProvider.notifier).loadProfileData(m['id']);
      }
    });
  }

  void _editProfile(Map<String, dynamic>? m) {
    if (m == null) return;
    final nameC = TextEditingController(text: m['name'] ?? '');
    final ownerC = TextEditingController(text: m['owner'] ?? '');
    final phoneC = TextEditingController(text: m['phone'] ?? '');
    final addressC = TextEditingController(text: m['address'] ?? '');
    final categoryC = TextEditingController(text: m['category'] ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Profil Resto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ClayTextField(label: 'Nama Resto', controller: nameC),
                  const SizedBox(height: 16),
                  ClayTextField(label: 'Pemilik', controller: ownerC),
                  const SizedBox(height: 16),
                  ClayTextField(label: 'Telepon', controller: phoneC, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  ClayTextField(label: 'Kategori', controller: categoryC),
                  const SizedBox(height: 16),
                  ClayTextField(label: 'Alamat', controller: addressC),
                  const SizedBox(height: 24),
                  ClayButton(label: 'Simpan', onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      ref.read(merchantProfileProvider.notifier).updateProfile({
                        'name': nameC.text.trim(),
                        'owner': ownerC.text.trim(),
                        'phone': phoneC.text.trim(),
                        'category': categoryC.text.trim(),
                        'address': addressC.text.trim(),
                      });
                      Navigator.pop(context);
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editHours(int index, List<Map<String, dynamic>> hours, String merchantId) {
    final h = hours[index];
    final openC = TextEditingController(text: h['open']);
    final closeC = TextEditingController(text: h['close']);
    bool isClosed = h['closed'];
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalCtx).viewInsets.bottom + 16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jam Operasional - ${h['day']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Tutup Toko Hari Ini', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Switch(
                        value: isClosed,
                        onChanged: (val) {
                          setModalState(() => isClosed = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!isClosed) ...[
                    Row(
                      children: [
                        Expanded(child: ClayTextField(label: 'Jam Buka', hint: '09:00', controller: openC)),
                        const SizedBox(width: 16),
                        Expanded(child: ClayTextField(label: 'Jam Tutup', hint: '21:00', controller: closeC)),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  ClayButton(label: 'Simpan', onPressed: () {
                    final updatedHours = List<Map<String, dynamic>>.from(hours);
                    updatedHours[index] = {
                      'day': h['day'],
                      'open': openC.text.trim(),
                      'close': closeC.text.trim(),
                      'closed': isClosed,
                    };
                    ref.read(merchantProfileProvider.notifier).updateOperatingHours(merchantId, updatedHours);
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addBankAccount(String merchantId) {
    final bankC = TextEditingController();
    final numberC = TextEditingController();
    final nameC = TextEditingController();
    bool setPrimary = false;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(modalCtx).viewInsets.bottom + 16),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tambah Rekening Bank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ClayTextField(label: 'Nama Bank (e.g. BCA, BNI)', controller: bankC),
                    const SizedBox(height: 16),
                    ClayTextField(label: 'Nomor Rekening', controller: numberC, keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    ClayTextField(label: 'Nama Pemilik Rekening', controller: nameC),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Set Rekening Utama', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        Switch(
                          value: setPrimary,
                          onChanged: (val) {
                            setModalState(() => setPrimary = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClayButton(label: 'Tambah', onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ref.read(merchantProfileProvider.notifier).addBankAccount(merchantId, {
                          'bank': bankC.text.trim().toUpperCase(),
                          'number': numberC.text.trim(),
                          'name': nameC.text.trim(),
                          'primary': setPrimary,
                        });
                        Navigator.pop(context);
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = ref.watch(merchantAuthProvider).merchant;
    final profileState = ref.watch(merchantProfileProvider);
    final hours = profileState.hours;
    final banks = profileState.banks;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Merchant')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ClayColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ClayColors.divider),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: ClayColors.primary,
                        child: const Icon(Icons.store, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m?['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            Text(m?['owner'] ?? '', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              Text(' ${(m?['rating'] as num?)?.toStringAsFixed(1) ?? '0.0'} • ${m?['total_orders'] ?? 0} ulasan'),
                            ]),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: ClayColors.primary),
                        onPressed: () => _editProfile(m),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(children: [
                    ListTile(leading: const Icon(Icons.phone), title: Text(m?['phone'] ?? ''), subtitle: const Text('Telepon')),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.category), title: Text(m?['category'] ?? ''), subtitle: const Text('Kategori')),
                    const Divider(height: 1),
                    ListTile(leading: const Icon(Icons.location_on), title: Text(m?['address'] ?? ''), subtitle: const Text('Alamat')),
                  ]),
                ),
                const SizedBox(height: 24),
                Row(
                  children: const [
                    Text('Jam Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Spacer(),
                    Icon(Icons.access_time, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                hours.isEmpty
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Tidak ada data jam operasional')),
                        ),
                      )
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: List.generate(hours.length, (i) {
                              final h = hours[i];
                              return ListTile(
                                title: Text(h['day'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      h['closed'] ? 'Tutup' : '${h['open']} - ${h['close']}',
                                      style: TextStyle(
                                        color: h['closed'] ? Colors.red : Colors.black87,
                                        fontWeight: h['closed'] ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                                  ],
                                ),
                                onTap: () => _editHours(i, hours, m!['id']),
                              );
                            }),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Rekening Settlement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: ClayColors.primary),
                      onPressed: () {
                        if (m != null && m['id'] != null) {
                          _addBankAccount(m['id']);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                banks.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Belum ada rekening bank yang terdaftar'),
                        ),
                      )
                    : Column(
                        children: List.generate(banks.length, (i) {
                          final b = banks[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: b['primary'] == true
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Atur sebagai Utama?'),
                                          content: const Text('Apakah Anda ingin mengatur rekening ini sebagai rekening settlement utama?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref.read(merchantProfileProvider.notifier).setPrimaryBankAccount(m!['id'], b['id']);
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('Ya'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                              child: ListTile(
                                leading: const Icon(Icons.account_balance, color: Colors.blue),
                                title: Text('${b['bank']} - ${b['number']}'),
                                subtitle: Text(b['name']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (b['primary'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Utama',
                                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () {
                                        ref.read(merchantProfileProvider.notifier).deleteBankAccount(m!['id'], b['id']);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                const SizedBox(height: 32),
                ClayButton(
                  label: 'Keluar Dari Akun',
                  backgroundColor: ClayColors.error,
                  onPressed: () {
                    ref.read(merchantAuthProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
            if (profileState.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
