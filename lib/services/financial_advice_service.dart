import 'dart:convert';
import 'package:http/http.dart' as http;

class FinancialAdviceService {
  static const String _baseUrl = 'http://localhost:3000/api/chat';

  Future<String> getFinancialAdvice(Map<String, dynamic> spendingData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a financial advisor analyzing spending patterns.',
            },
            {
              'role': 'user',
              'content':
              'Here are my spending patterns, please provide specific advice on how to improve my financial situation: ${jsonEncode(spendingData)}',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to get financial advice: ${errorData['error']['message']}');
      }
    } catch (e) {
      return 'Не удалось получить финансовый совет: $e';
    }
  }
}
