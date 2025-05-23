import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'crisis_map.dart'; // Импортируй путь к карте правильно

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeaderSection(),
              SizedBox(height: 24),
              _MenuButtons(),
              SizedBox(height: 24),
              CrisisCentersPreview(),
              SizedBox(height: 24),
              EmergencyNumbersSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset("assets/icons/button_pink.png", width: 28),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [


              Text("Ты прекрасна!", style: TextStyle(fontSize: 18, color: Color(0xFFD38095))),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.pinkAccent,
          child: Text("👩‍🦰", style: TextStyle(fontSize: 20)),
        )
      ],
    );
  }
}

class _MenuButtons extends StatelessWidget {
  const _MenuButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _MenuCard(title: "Форум", iconPath: "assets/icons/forum.png"),
        SizedBox(width: 16),
        _MenuCard(title: "Чат", iconPath: "assets/icons/chat.png"),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String iconPath;

  const _MenuCard({required this.title, required this.iconPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Color(0xFFF9EDEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(iconPath, width: 40, height: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Color(0xFFB56E78), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class CrisisCentersPreview extends StatelessWidget {
  const CrisisCentersPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final Set<Marker> previewMarkers = {
      const Marker(
        markerId: MarkerId("preview1"),
        position: LatLng(51.125, 71.443),
      ),
      const Marker(
        markerId: MarkerId("preview2"),
        position: LatLng(51.132, 71.445),
      ),
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CrisisMapScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFF9EDEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Кризисные центры", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFB56E78))),
                const SizedBox(width: 6),
             
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AbsorbPointer(
                absorbing: true,
                child: SizedBox(
                  height: 150,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(51.128, 71.430),
                      zoom: 11,
                    ),
                    markers: previewMarkers,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyNumbersSection extends StatelessWidget {
  const EmergencyNumbersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF9EDEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Text("Горячие номера связи", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              SizedBox(width: 6),
              Icon(Icons.expand_more),
            ],
          ),
          SizedBox(height: 12),
          Text("• Единый контакт-центр - 1414", style: TextStyle(fontSize: 14, color: Colors.black87)),
          Text("• Линия доверия для детей и молодежи - 150", style: TextStyle(fontSize: 14, color: Colors.black87)),
          Text("• iKomek - 109", style: TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}