import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences.dart';

class ChatService {
  static const String _baseUrl = 'https://qorgai-backend-0odv.onrender.com/api';
  static const String _chatEndpoint = '/chat';

  Future<String> sendMessage(String message) async {
    try {
      print('Sending message to backend...');
      print('URL: $_baseUrl$_chatEndpoint');
      print('Message: $message');

      final response = await http.post(
        Uri.parse('$_baseUrl$_chatEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'https://qorgai-frontend-0odv.onrender.com',
        },
        body: jsonEncode({
          'message': message,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Ошибка при отправке сообщения');
      }
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Ошибка при отправке сообщения: $e');
    }
  }
} 