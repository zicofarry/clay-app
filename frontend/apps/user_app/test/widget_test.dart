import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const UserApp());
    expect(find.text('Clay'), findsWidgets);
  });
}
