import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/widgets/exit_confirmation_scope.dart';

void main() {
  testWidgets('shows exit confirmation when back navigation is triggered', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ExitConfirmationScope(
          child: Scaffold(
            body: Center(child: Text('Home')),
          ),
        ),
      ),
    );

    tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Exit app?'), findsOneWidget);
    expect(find.text('Do you want to close SpendWise?'), findsOneWidget);
  });
}
