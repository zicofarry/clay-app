import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label berhasil disalin ke clipboard')),
    );
  }

  void _editProfile(Map<String, dynamic>? m) {
    if (m == null) return;
    final nameC = TextEditingController(text: m['name'] ?? '');
    final phoneC = TextEditingController(text: m['phone'] ?? '');
    final descriptionC = TextEditingController(text: m['description'] ?? '');
    final addressC = TextEditingController(text: m['address'] ?? '');
    final latC = TextEditingController(text: (m['lat'] ?? '').toString());
    final lngC = TextEditingController(text: (m['lng'] ?? '').toString());
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 16),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Profil Resto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ClayTextField(
                    label: 'Nama Resto',
                    controller: nameC,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ClayTextField(
                    label: 'Telepon',
                    controller: phoneC,
                    keyboardType: TextInputType.phone,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  ClayTextField(
                    label: 'Deskripsi',
                    controller: descriptionC,
                  ),
                  const SizedBox(height: 16),
                  ClayTextField(
                    label: 'Alamat',
                    controller: addressC,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ClayTextField(
                          label: 'Latitude',
                          controller: latC,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Harus diisi';
                            final d = double.tryParse(val);
                            if (d == null) return 'Desimal salah';
                            if (d < -90.0 || d > 90.0) return '-90 s/d 90';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClayTextField(
                          label: 'Longitude',
                          controller: lngC,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Harus diisi';
                            final d = double.tryParse(val);
                            if (d == null) return 'Desimal salah';
                            if (d < -180.0 || d > 180.0) return '-180 s/d 180';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ClayButton(
                    label: 'Simpan',
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ref.read(merchantProfileProvider.notifier).updateProfile({
                          'name': nameC.text.trim(),
                          'phone': phoneC.text.trim(),
                          'description': descriptionC.text.trim(),
                          'address': addressC.text.trim(),
                          'lat': double.tryParse(latC.text.trim()),
                          'lng': double.tryParse(lngC.text.trim()),
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editOperatingHours(String merchantId, List<Map<String, dynamic>> currentHours) {
    final List<String> dayNames = [
      'Minggu', // 0
      'Senin',  // 1
      'Selasa', // 2
      'Rabu',   // 3
      'Kamis',  // 4
      'Jumat',  // 5
      'Sabtu',  // 6
    ];

    // Build exactly 7 days: Monday (1) to Saturday (6), then Sunday (0)
    final List<Map<String, dynamic>> localHours = [];
    final List<int> sortedDayOfWeekIndices = [1, 2, 3, 4, 5, 6, 0];

    for (final dayIdx in sortedDayOfWeekIndices) {
      final existing = currentHours.firstWhere(
        (h) => h['day_of_week'] == dayIdx || h['day'] == dayNames[dayIdx],
        orElse: () => <String, dynamic>{},
      );

      if (existing.isNotEmpty) {
        localHours.add(Map<String, dynamic>.from(existing));
      } else {
        localHours.add({
          'day': dayNames[dayIdx],
          'open': '09:00',
          'close': '21:00',
          'closed': false,
          'day_of_week': dayIdx,
        });
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Edit Jam Operasional', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    itemCount: localHours.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final h = localHours[index];
                      final isClosed = h['closed'] == true;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  h['day'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                const Text('Tutup'),
                                Switch(
                                  value: isClosed,
                                  activeThumbColor: Colors.red,
                                  onChanged: (val) {
                                    setModalState(() {
                                      h['closed'] = val;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (!isClosed) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final initialTime = _parseTimeOfDay(h['open'] ?? '09:00');
                                        final selected = await showTimePicker(
                                          context: context,
                                          initialTime: initialTime,
                                        );
                                        if (selected != null) {
                                          setModalState(() {
                                            h['open'] = _formatTimeOfDay(selected);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text('Buka: ${h['open'] ?? "09:00"}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final initialTime = _parseTimeOfDay(h['close'] ?? '21:00');
                                        final selected = await showTimePicker(
                                          context: context,
                                          initialTime: initialTime,
                                        );
                                        if (selected != null) {
                                          setModalState(() {
                                            h['close'] = _formatTimeOfDay(selected);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                            const SizedBox(width: 8),
                                            Text('Tutup: ${h['close'] ?? "21:00"}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ClayButton(
                  label: 'Simpan Jam Operasional',
                  onPressed: () {
                    ref.read(merchantProfileProvider.notifier).updateOperatingHours(merchantId, localHours);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 16),
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
    ref.listen<MerchantProfileState>(
      merchantProfileProvider,
      (previous, next) {
        if (next.error != null && next.error != previous?.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    final m = ref.watch(merchantAuthProvider).merchant;
    final profileState = ref.watch(merchantProfileProvider);
    final banks = profileState.banks;

    final isShopActive = m?['status'] == 'active';
    final isStatusToggleable = m?['status'] == 'active' || m?['status'] == 'closed';

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
                            if (m?['slug'] != null && m!['slug'].toString().isNotEmpty)
                              Text('@${m['slug']}', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
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
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isShopActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                          child: Icon(
                            isShopActive ? Icons.storefront : Icons.storefront,
                            color: isShopActive ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isShopActive
                                    ? 'Toko Buka (Aktif)'
                                    : (m?['status'] == 'pending_review'
                                        ? 'Menunggu Peninjauan'
                                        : (m?['status'] == 'suspended'
                                            ? 'Ditangguhkan'
                                            : 'Toko Tutup (Nonaktif)')),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                isStatusToggleable
                                    ? (isShopActive ? 'Pelanggan dapat melakukan pemesanan' : 'Pelanggan tidak dapat memesan')
                                    : (m?['status'] == 'pending_review'
                                        ? 'Akun Anda sedang diverifikasi admin'
                                        : 'Akun Anda ditangguhkan oleh admin'),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isStatusToggleable)
                          Switch(
                            value: isShopActive,
                            onChanged: (val) {
                              final newStatus = val ? 'active' : 'closed';
                              ref.read(merchantProfileProvider.notifier).updateStatus(m!['id'], newStatus);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(m?['phone'] ?? '-'),
                        subtitle: const Text('Telepon'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: Text(m?['category'] ?? '-'),
                        subtitle: const Text('Kategori'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(m?['slug'] ?? '-'),
                        subtitle: const Text('Slug Toko'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(m?['description'] ?? 'Tidak ada deskripsi'),
                        subtitle: const Text('Deskripsi'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(m?['address'] ?? '-'),
                        subtitle: const Text('Alamat'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.map_outlined),
                        title: Text('Lat: ${m?['lat'] ?? '-'}, Lng: ${m?['lng'] ?? '-'}'),
                        subtitle: const Text('Koordinat Lokasi (Latitude, Longitude)'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_formatDate(m?['created_at'])),
                        subtitle: const Text('Tanggal Bergabung'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.fingerprint),
                        title: Text(m?['id'] ?? '-'),
                        subtitle: const Text('ID Toko'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            if (m?['id'] != null) {
                              _copyToClipboard(m!['id'], 'ID Toko');
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(m?['owner_id'] ?? '-'),
                        subtitle: const Text('ID Pemilik'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            if (m?['owner_id'] != null) {
                              _copyToClipboard(m!['owner_id'], 'ID Pemilik');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Jam Operasional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (m != null && m['id'] != null)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: ClayColors.primary),
                                onPressed: () {
                                  _editOperatingHours(m['id'], profileState.hours);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (profileState.hours.isEmpty)
                          const Center(child: Text('Belum ada data jam operasional'))
                        else
                          Column(
                            children: profileState.hours.map((h) {
                              final isOpen = h['closed'] == false;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(h['day'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        isOpen ? '${h['open']} - ${h['close']}' : 'Tutup',
                                        style: TextStyle(
                                          color: isOpen ? Colors.black87 : Colors.red,
                                          fontWeight: isOpen ? FontWeight.normal : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
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
                    ? const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(
                            child: Text('Belum ada rekening bank yang terdaftar'),
                          ),
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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 2),
                                    Text(b['name']),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          b['is_verified'] == true ? Icons.check_circle : Icons.pending,
                                          size: 14,
                                          color: b['is_verified'] == true ? Colors.green : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          b['is_verified'] == true ? 'Terverifikasi' : 'Belum Terverifikasi',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: b['is_verified'] == true ? Colors.green : Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
