import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ChatService {
  // Используем разные URL для разработки и продакшена
  final String baseUrl = kDebugMode 
      ? 'http://localhost:5000'  // Локальный URL для разработки
      : 'https://qorgai-backend.onrender.com';  // URL на Render

  Future<String> sendMessage(String message, {int? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
} 