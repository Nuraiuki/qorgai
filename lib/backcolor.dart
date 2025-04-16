import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // добавь flutter_svg в pubspec.yaml

class BackgroundWithIcons extends StatelessWidget {
  const BackgroundWithIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color.fromARGB(255, 237, 171, 179), // светло-розовый
            Color.fromARGB(255, 236, 231, 231), // светлее у краев
            
          ],
        ),
      ),
      // child: Stack(
      //   children: [
      //     // Пример: разместим иконки по экрану (можешь заменить на свои SVG или PNG)
      //     Positioned(
      //       top: 60,
      //       left: 40,
      //       child: SvgPicture.asset('assets/icons/lock.svg', width: 24, color: Colors.white38),
      //     ),
      //     Positioned(
      //       bottom: 100,
      //       right: 30,
      //       child: SvgPicture.asset('assets/icons/shield.svg', width: 28, color: Colors.white38),
      //     ),
      //     // ...добавь остальные иконки по своему вкусу
      //   ],
      // ),
    );
  }
}
