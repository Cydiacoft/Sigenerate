import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_sign_generator/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrafficSignApp());
    expect(find.text('道路交通标志生成器'), findsOneWidget);
  });
}
