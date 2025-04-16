import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qorgai/main.dart';
import 'package:easy_localization/easy_localization.dart';

void main() {
  testWidgets('Onboarding shows Start button', (WidgetTester tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('ru'), Locale('kk')],
        path: 'assets/translations',
        fallbackLocale: const Locale('ru'),
        child: const QorgaiApp(),
      ),
    );

    await tester.pumpAndSettle(); // обязательно для локализации

    expect(find.text('Начать!'), findsOneWidget);
  });
}
