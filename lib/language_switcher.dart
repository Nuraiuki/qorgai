import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: PopupMenuButton<String>(
        tooltip: 'Выбор языка',
        offset: const Offset(0, 48),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        color: const Color(0xFFF5F0F2), // Нежный фон
        icon: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF6D9B6F),
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(Icons.language, color: Colors.white, size: 26),
        ),
       onSelected: (String newLang) async {
  await Future.delayed(const Duration(milliseconds: 100));
  if (!context.mounted) return;
  context.setLocale(Locale(newLang));
},
        itemBuilder: (BuildContext context) => [
          PopupMenuItem(
            value: 'ru',
            child: Row(
              children: const [
                Text('🇷🇺', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Text(
                  'Русский',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'kk',
            child: Row(
              children: const [
                Text('🇰🇿', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Text(
                  'Қазақша',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
