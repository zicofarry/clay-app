import 'package:flutter/material.dart';
import 'package:clay_ui/clay_ui.dart';

class PlaceholderScreen extends StatelessWidget {
  final String serviceName;
  const PlaceholderScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: ClayColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              '$serviceName coming soon',
              style: TextStyle(fontSize: 18, color: ClayColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
