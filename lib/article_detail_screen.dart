  import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({Key? key}) : super(key: key);

  final String title = 'Ваши права при задержании полицией';

  final String content = '''
Быть задержанной полицией — стрессовая ситуация. Особенно важно для женщин знать свои законные права:

🔹 Вы имеете право **знать причину задержания**. Требуйте, чтобы сотрудник полиции представился и назвал основание.

🔹 Вы не обязаны **давать показания против себя**. Это право гарантировано Конституцией.

🔹 Вы имеете право на **адвоката**. Даже если вы не можете оплатить услуги, вы имеете право на бесплатную юридическую помощь.

🔹 Если вы беременны, ухаживаете за малолетними детьми или имеете проблемы со здоровьем — **сообщите об этом немедленно**.

🔹 Вас не имеют права обыскивать без вашего согласия или соответствующего постановления. Женщину должна обыскивать только женщина-сотрудник полиции.

🔹 Требуйте, чтобы при задержании был составлен **протокол** и вы получили его копию. Не подписывайте ничего, если не уверены в содержании.

🔹 Если вы подверглись **принуждению, угрозам или насилию**, вы имеете право подать жалобу. Зафиксируйте любые повреждения, обратитесь к врачу, сделайте фотографии.

Помните: знание своих прав — ваш главный инструмент в защите себя.

Сохраните этот текст, поделитесь с подругами. Вместе мы сильнее!
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF5F4),
      appBar: AppBar(
        title: Text('Статья'),
        backgroundColor: Color(0xFFFAF5F4),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.pinkAccent),
        titleTextStyle: TextStyle(color: Colors.pinkAccent, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                content,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
