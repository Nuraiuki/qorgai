import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  static const String baseUrl = 'https://qorgai-backend-0odv.onrender.com';

  Future<String> sendMessage(String message, int userId) async {
    try {
      debugPrint('Sending message to: $baseUrl/api/chat');
      debugPrint('Message: $message');
      debugPrint('User ID: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'https://qorgai-frontend-0odv.onrender.com',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Извините, произошла ошибка';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Ошибка при отправке сообщения');
      }
    } catch (e) {
      debugPrint('Error in sendMessage: $e');
      throw Exception('Ошибка при отправке сообщения: $e');
    }
  }
} 