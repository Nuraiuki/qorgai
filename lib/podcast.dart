import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> {
  final _audioPlayer = AudioPlayer();

  final List<Map<String, String>> podcasts = const [
    {
      'title': 'Права при задержании',
      'description': 'Узнайте, как вести себя при задержании полицией. Ваши законные права, что можно и чего нельзя делать.',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    },
    {
      'title': 'Юридическая помощь при разводе',
      'description': 'Развод — трудный этап. Какие документы нужны? Как защитить права женщин и детей?',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    },
    {
      'title': 'Домашнее насилие: ваши шаги',
      'description': 'Что делать, если вы столкнулись с насилием? Куда обращаться и как подать заявление?',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    },
  ];
bool isPlaying = false;

  void _showPodcastModal(BuildContext context, Map<String, String> podcast) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Text(
                podcast['title'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                podcast['description'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              
ElevatedButton.icon(
  onPressed: () async {
    final url = podcast['url'];
    if (url != null) {
      try {
        if (!_audioPlayer.playing) {
          await _audioPlayer.setUrl(url);
          await _audioPlayer.play();
          setState(() => isPlaying = true);
        } else {
          await _audioPlayer.pause();
          setState(() => isPlaying = false);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  },
  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
  label: Text(isPlaying ? 'Пауза' : 'Воспроизвести'),
),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F4),
      appBar: AppBar(
        title: const Text('Подкасты'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFAF5F4),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.pinkAccent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      body: ListView.builder(
        itemCount: podcasts.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final podcast = podcasts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                podcast['title'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_fill, color: Colors.pinkAccent, size: 32),
                onPressed: () => _showPodcastModal(context, podcast),
              ),
              onTap: () => _showPodcastModal(context, podcast),
            ),
          );
        },
      ),
    );
  }
}
