import 'package:flutter/material.dart';
import 'article_detail_screen.dart';
class ArticleScreen extends StatelessWidget {
  final List<Map<String, String>> articles = [
    {
      'title': 'Где получить бесплатную юридическую помощь?',
      'description': 'Обзор организаций, которые помогают женщинам в кризисной ситуации.',
    },
    {
      'title': 'Как составить жалобу в суд?',
      'description': 'Пошаговая инструкция от юриста.',
    },
    {
      'title': 'Ваши права при задержании полицией',
      'description': 'Что можно, а что нельзя — в ситуациях давления и обыска.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF5F4),
      appBar: AppBar(
        title: Text('Статьи'),
        backgroundColor: Color(0xFFFAF5F4),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.pinkAccent),
        titleTextStyle: TextStyle(color: Colors.pinkAccent, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFD9A8A0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              title: Text(article['title']!,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(article['description']!,
                  style: TextStyle(color: Colors.white.withOpacity(0.9))),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
             onTap: () {
  if (article['title'] == 'Ваши права при задержании полицией') {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticleDetailScreen()),
    );
  }
},

            ),
          );
        },
      ),
    );
  }
}
