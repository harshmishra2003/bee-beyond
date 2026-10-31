import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bee_beeyond/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BeeBeyondApp(),
      ),
    );
    expect(find.byType(BeeBeyondApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
