import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  int _rating = 0;
  bool _submitted = false;

  void _submit() {
    setState(() => _submitted = true);
    final message = _rating >= 4
        ? 'Terima kasih! 🙏 Kami senang kamu suka Clay.'
        : _rating == 3
            ? 'Terima kasih atas masukannya. Kami akan tingkatkan.'
            : 'Maah mendengar itu. Tim kami akan menindaklanjuti.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beri Rating')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ClayColors.primary, ClayColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bagaimana pengalamanmu memakai Clay?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masukanmu sangat berarti bagi kami',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: _submitted ? null : () => setState(() => _rating = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                        size: 44,
                        color: i <= _rating ? Colors.amber : ClayColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _rating == 0
                  ? 'Tap bintang untuk memberi rating'
                  : _rating == 1
                      ? 'Sangat buruk'
                      : _rating == 2
                          ? 'Kurang puas'
                          : _rating == 3
                              ? 'Cukup'
                              : _rating == 4
                                  ? 'Bagus'
                                  : 'Sangat memuaskan!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _rating >= 4 ? Colors.amber.shade800 : ClayColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (_rating > 0 && !_submitted) ...[
            const Text(
              'Ceritakan pengalamanmu (opsional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Apa yang kamu suka atau ingin ditingkatkan?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Kirim Rating'),
              ),
            ),
          ],
          if (_submitted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ratingmu sudah kami terima. Terima kasih!',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
