import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'edu.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages =  [
    HomeScreen(),
    TomirisHomeScreen(),
    EduScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFDEBEB),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(
                iconAsset: "assets/icons/icon_home.png",
                index: 0,
                isSelected: _selectedIndex == 0,
                onTap: _onItemTapped,
              ),
              _NavIcon(
                iconData: Icons.favorite_border, // ← Flutter-иконка
                index: 1,
                isSelected: _selectedIndex == 1,
                onTap: _onItemTapped,
              ),
              _NavIcon(
                iconAsset: "assets/icons/icon_study.png",
                index: 2,
                isSelected: _selectedIndex == 2,
                onTap: _onItemTapped,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String? iconAsset;
  final IconData? iconData;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const _NavIcon({
    this.iconAsset,
    this.iconData,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFD25959) : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Opacity(
        opacity: isSelected ? 1.0 : 0.4,
        child: iconAsset != null
            ? Image.asset(
                iconAsset!,
                width: 40,
                height: 40,
                color: color,
              )
            : Icon(
                iconData,
                size: 32,
                color: color,
              ),
      ),
    );
  }
}
