import 'package:dio/dio.dart';

class GeminiService {
  final Dio _dio;
  final String _apiKey;

  GeminiService(this._dio, {required String apiKey}) : _apiKey = apiKey;

  // Query OpenAI/OpenRouter chat endpoint
  Future<String?> _queryOpenRouter(String systemPrompt, String userPrompt) async {
    try {
      final response = await _dio.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'HTTP-Referer': 'https://legibris.com', // Required by OpenRouter
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'google/gemini-2.5-flash',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt}
          ]
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          return choices.first['message']['content'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('OpenRouter Gemini Integration Error: $e');
      return null;
    }
  }

  // Feature A: Summarize Book
  Future<String?> summarizeBook(String title, String author) async {
    final system = 'Actúas como un crítico literario y asistente de lectura experto para Legibris.';
    final user = 'Genera un resumen ejecutivo del libro "$title" de $author. Divide la respuesta en: Sinopsis corta y Temas clave. Evita spoilers.';
    return _queryOpenRouter(system, user);
  }

  // Feature B: Reading Assistant context-aware of page progress
  Future<String?> askAboutBook(String title, String question, int progressPercentage) async {
    final system = 'Eres un bibliotecario inteligente de Legibris. Conversas con un usuario que ha leído el $progressPercentage% del libro "$title".';
    final user = 'Pregunta: "$question". Regla estricta: NUNCA reveles acontecimientos del libro posteriores a ese progreso.';
    return _queryOpenRouter(system, user);
  }
}
