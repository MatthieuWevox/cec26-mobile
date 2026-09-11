import 'package:cec2026/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('le design system affiche une action principale', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Continuer'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Continuer'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
