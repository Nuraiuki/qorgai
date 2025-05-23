import 'package:flutter/material.dart';
class AppHeader extends StatelessWidget {
  final String name;
  final String emoji;
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    required this.name,
    this.emoji = '👩‍🦰',
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // верхняя строка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset("assets/icons/button_pink.png", width: 28),

              /// 👇 добавлен GestureDetector
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFD9B3B3),
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // приветствие
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$name,",
                style: const TextStyle(
                  fontSize: 42,
                  fontFamily: 'Balmoral',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B8E4E),
                  height: 0.8,
                ),
              ),
              const Text(
                "ты прекрасна!",
                style: TextStyle(fontSize: 18, color: Color(0xFFD38095)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
