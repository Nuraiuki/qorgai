import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'onboarding_screen.dart'; // не забудь изменить путь под свою структуру

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ru'),
        Locale('kk'),
      ],
      path: 'assets/translations', // путь к JSON-файлам
      fallbackLocale: const Locale('ru'),
      saveLocale: true, 
      child: const QorgaiApp(),
    ),
  );
}

class QorgaiApp extends StatelessWidget {
  const QorgaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qorgai',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: ThemeData(
        fontFamily: 'Inter', 
        scaffoldBackgroundColor: const Color(0xFFF1DFE0),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
