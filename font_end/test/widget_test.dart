import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:origami_app/main.dart';
import 'package:origami_app/core/providers/auth_provider.dart';

void main() {
  testWidgets('App starts with splash screen and displays title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const OrigamiApp(),
      ),
    );

    // Verify that our splash screen text is shown.
    expect(find.text('Gấp giấy promax'), findsOneWidget);
  });
}
