import 'package:flutter/material.dart';
import 'podcast.dart';
import 'article.dart';

class EduScreen extends StatelessWidget {
  final List<Map<String, String>> podcasts = [
    {
      'title': 'Права женщин при разводе',
      'description': 'Что нужно знать при разделе имущества и опеки.',
    },
    {
      'title': 'Юридическая помощь пострадавшим от насилия',
      'description': 'Как действовать, куда обращаться, и что важно учесть.',
      
    },
    {
      'title': 'Рабочие права женщин в Казахстане',
      'description': 'Как защитить свои трудовые права и избежать дискриминации.',
    
    },
     {
    'title': 'Как защитить себя в суде',
    'description': 'Советы и процедуры при подаче искового заявления.',

  },
  {
    'title': 'Психологическая поддержка при стрессе',
    'description': 'Ресурсы и техники для снятия напряжения.',
   
  },
  ];

  final List<Map<String, String>> articles = [
    {
      'title': 'Как получить бесплатную юридическую помощь?',
      'description': 'Пошаговая инструкция и список организаций.',

    },
    {
      'title': 'Что делать, если ваши права нарушены?',
      'description': 'Руководство по действиям и обращениям в суд.',
     
    },
    {
      'title': 'Права беременных женщин на работе',
      'description': 'Что запрещено работодателю и как себя защитить.',

    },
    {
    'title': 'Материнский (семейный) отпуск',
    'description': 'Как оформить и на каких условиях предоставляется.',
    
  },
  {
    'title': 'Защита от увольнения',
    'description': 'Ваши права при расторжении трудового договора.',

  },
  {
    'title': 'Порядок подачи жалобы в прокуратуру',
    'description': 'Куда и как правильно направить обращение.',
   
  },
  ];
  @override
  Widget build(BuildContext context) {
    const bgColor     = Color(0xFFFAF5F4);
    const accentColor = Color(0xFFF9EDEE);
    const headerColor = Color(0xFFAD4E56);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Образование',
          style: TextStyle(color: headerColor, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: headerColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        // ListView сам скроллится и не даст Column вылезти за экран
        child: ListView(
          children: [
            sectionHeader(
              title: 'Подкасты',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PodcastScreen()),
              ),
            ),
            SizedBox(height: 12),
            buildHorizontalList(
              podcasts,
              Colors.white,               // cardColor
              textColor: Colors.black87,
              cardBg: accentColor,
            ),
            SizedBox(height: 30),
            sectionHeader(
              title: 'Статьи',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ArticleScreen()),
              ),
            ),
            SizedBox(height: 12),
            buildHorizontalList(
              articles,
              Colors.white,               // cardColor
              textColor: Colors.black87,
              cardBg: accentColor,
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }


  Widget sectionHeader({required String title, required VoidCallback onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFAD4E56)),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'смотреть все ➤',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget buildHorizontalList(List<Map<String, String>> items, Color cardColor,
      {Color? textColor, Color? cardBg}) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: cardBg ?? cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor ?? Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['description']!,
                            style: TextStyle(color: textColor ?? Colors.white),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
