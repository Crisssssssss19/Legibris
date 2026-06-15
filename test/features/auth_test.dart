import 'package:flutter_test/flutter_test.dart';

// Helper validator logic to test
bool validateEmail(String email) {
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool validatePassword(String password) {
  return password.length >= 6;
}

void main() {
  group('Auth validation logic tests', () {
    test('should validate correct email formats', () {
      expect(validateEmail('test@legibris.com'), true);
      expect(validateEmail('cris.lector@gmail.com'), true);
    });

    test('should invalidate wrong email formats', () {
      expect(validateEmail('testlegibris.com'), false);
      expect(validateEmail('test@legibris'), false);
    });

    test('should validate password length constraints', () {
      expect(validatePassword('12345'), false); // too short
      expect(validatePassword('123456'), true); // compliant
    });
  });
}
