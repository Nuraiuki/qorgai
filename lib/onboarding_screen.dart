import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'language_switcher.dart';
import 'backcolor.dart';
import 'auth_screen.dart'; 

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1DFE0),
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundWithIcons(), // Градиент + иконки
            
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeScreen(),
                _buildInfoScreen(),
              ],
            ),
          Padding(
  padding: const EdgeInsets.all(30),
  child: Align(
    alignment: Alignment.topLeft,
    child: LanguageSwitcher(),
  ),
),

          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward, size: 30,color: Color(0xFF6C8A64)),
              onPressed: _nextPage,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _chatBubble(
                    context.tr("welcome_1"),
                    key: ValueKey("welcome_1_${context.locale.languageCode}"),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _chatBubble(
                    context.tr("welcome_2"),
                    key: ValueKey("welcome_2_${context.locale.languageCode}"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildInfoScreen() {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
       
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
color: Colors.black.withAlpha((0.05 * 255).toInt()), // 13
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Qorgai",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF9E6B6B),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr("description"),
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Color(0xFF9E6B6B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton(
         onPressed: () {
            debugPrint("Кнопка нажата");

 Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));

},



          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 128, 169, 116),
            padding: const EdgeInsets.symmetric(horizontal: 76, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 4,
          ),
          child: Text(
            context.tr("start"),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _chatBubble(String text, {Key? key}) {
  return Container(
    key: key,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
color: Colors.black.withAlpha((0.05 * 255).toInt()), // 13
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18, // увеличено
        fontWeight: FontWeight.w400,
        color: Colors.black87,
      ),
    ),
  );
}

}
