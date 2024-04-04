import 'package:flutter_test/flutter_test.dart';
import 'package:login_flow/feature_layer/login/login.dart';

void main() {
  const mockEmail = 'mock@email.com';
  group('Email', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        const email = Email.pure();
        expect(email.value, '');
        expect(email.isPure, isTrue);
      });

      test('dirty creates correct instance', () {
        const email = Email.dirty(mockEmail);
        expect(email.value, mockEmail);
        expect(email.isPure, isFalse);
      });
    });

    group('validator', () {
      test('returns empty error when email is empty', () {
        expect(
          const Email.dirty().error,
          EmailValidationError. invalid,
        );
      });

      test('is valid when email is not empty', () {
        expect(
          const Email.dirty(mockEmail).error,
          isNull,
        );
      });
    });
  });
}
