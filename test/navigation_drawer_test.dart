import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spendwise/providers/theme_provider.dart';
import 'package:spendwise/widgets/app_drawer.dart';

void main() {
  testWidgets('drawer shows navigation options and logout', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            drawer: const AppDrawer(
              currentIndex: 0,
              onDestinationSelected: _noop,
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Home Screen'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('drawer shows dark mode toggle', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Test')),
            drawer: const AppDrawer(
              currentIndex: 0,
              onDestinationSelected: _noop,
            ),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Dark Mode'), findsOneWidget);

    final drawerContext = tester.element(find.byType(AppDrawer));
    expect(Provider.of<ThemeProvider>(drawerContext, listen: false).isDarkMode, isFalse);

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(Provider.of<ThemeProvider>(drawerContext, listen: false).isDarkMode, isTrue);
  });
}

void _noop(int _) {}
