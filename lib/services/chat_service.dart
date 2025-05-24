import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'https://qorgai-backend.onrender.com';

  Future<String> sendMessage(String message, int userId) async {
    try {
      print('Отправка сообщения на: $baseUrl/api/chat'); // Логирование
      print('Тело запроса: {"message": "$message", "user_id": $userId}'); // Логирование

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      );

      print('Статус ответа: ${response.statusCode}'); // Логирование
      print('Тело ответа: ${response.body}'); // Логирование

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Ошибка: пустой ответ от сервера';
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Ошибка при отправке сообщения');
      }
    } catch (e) {
      print('Ошибка в sendMessage: $e'); // Логирование
      throw Exception('Ошибка соединения с сервером: $e');
    }
  }
} 