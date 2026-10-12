import 'package:flutter_test/flutter_test.dart';
import 'package:bee_beeyond/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BeeBeyondApp());
    expect(find.byType(BeeBeyondApp), findsOneWidget);
  });
}
