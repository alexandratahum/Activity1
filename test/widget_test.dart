import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:portfolio_app/main.dart';
import 'package:portfolio_app/state/app_settings.dart';

Future<void> pumpApp(WidgetTester tester) {
  return tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const PortfolioApp(),
    ),
  );
}

void main() {
  testWidgets('home dashboard shows global profile and routes to activities', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Welcome back, Portfolio Developer'), findsOneWidget);
    expect(find.text('Counter Lab'), findsOneWidget);
    expect(find.text('Layout Explorer'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Counter Lab'), 300);
    await tester.tap(find.text('Counter Lab'));
    await tester.pumpAndSettle();
    expect(find.text('Local screen state'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Increment'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back, Portfolio Developer'), findsOneWidget);
  });

  testWidgets('home remains usable on narrow and wide viewports', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());

    for (final size in <Size>[const Size(360, 640), const Size(1200, 800)]) {
      debugPrint('VIEW $size DPR ${tester.view.devicePixelRatio}');
      tester.view.physicalSize = size;
      await tester.pump();
      await pumpApp(tester);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back, Portfolio Developer'), findsOneWidget);
      expect(find.text('Counter Lab'), findsOneWidget);
    }
  });

  testWidgets('settings updates global profile and theme on home', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Open settings'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Flutter Learner');
    await tester.pump();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Flutter Learner'), findsOneWidget);
    expect(find.text('Dark theme is active'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
