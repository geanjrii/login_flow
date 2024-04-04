// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:login_flow/feature_layer/login/login.dart';

void main() {
  const mockPassword = 'ValidPassword123';
  group('Password', () {
    group('constructors', () {
      test('pure creates correct instance', () {
        final password = Password.pure();
        expect(password.value, '');
        expect(password.isPure, isTrue);
      });

      test('dirty creates correct instance', () {
        final password = Password.dirty(mockPassword);
        expect(password.value, mockPassword);
        expect(password.isPure, isFalse);
      });
    });

    group('validator', () {
      test('returns empty error when password is empty', () {
        expect(
          Password.dirty().error,
          PasswordValidationError.invalid,
        );
      });

      test('is valid when password is not empty', () {
        expect(
          Password.dirty(mockPassword).error,
          isNull,
        );
      });
    });
  });
}
