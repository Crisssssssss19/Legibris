import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ResendService {
  final Dio _dio;
  final String _apiKey;

  ResendService(this._dio, {required String apiKey}) : _apiKey = apiKey;

  // Send an email notification using Resend API
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String htmlContent,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.resend.com/emails',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'from': 'Legibris <notificaciones@legibris.com>',
          'to': [to],
          'subject': subject,
          'html': htmlContent,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Resend Email Dispatch Error: $e');
      return false;
    }
  }

  // Welcome Email template helper
  Future<bool> sendWelcomeEmail(String toAddress, String username) {
    final html = '''
      <h1>¡Bienvenido a Legibris, $username!</h1>
      <p>Tu estantería personal está lista. Empieza a registrar tus lecturas y a crear metas hoy mismo.</p>
    ''';
    return sendEmail(to: toAddress, subject: 'Bienvenido a Legibris 📖', htmlContent: html);
  }
}
