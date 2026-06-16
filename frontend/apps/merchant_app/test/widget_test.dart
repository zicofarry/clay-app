import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/app.dart';

void main() {
  testWidgets('MerchantApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MerchantApp());
    expect(find.text('Clay Merchant'), findsOneWidget);
  });
}
