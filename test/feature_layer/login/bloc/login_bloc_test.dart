import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formz/formz.dart';
import 'package:login_flow/domain_layer/domain_layer.dart';
import 'package:login_flow/feature_layer/login/login.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

void main() {
  const mockEmail = 'mock@email.com';
  const mockPassword = 'ValidPassword123';


  late AuthenticationRepository authenticationRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
  });

  LoginBloc buildBloc() {
    return LoginBloc(
      authenticationRepository: authenticationRepository,
    );
  }

  group('LoginBloc', () {
    test('initial state is LoginState', () {
      expect(buildBloc().state, const LoginState());
    });

    group('LoginSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [submissionInProgress, submissionSuccess] '
        'when login succeeds',
        setUp: () {
          when(
            () => authenticationRepository.logIn(
              email: mockEmail,
              password: mockPassword,
            ),
          ).thenAnswer((_) => Future<String>.value('user'));
        },
        build: buildBloc,
        act: (bloc) {
          bloc
            ..add(const LoginUsernameChanged(mockEmail))
            ..add(const LoginPasswordChanged(mockPassword))
            ..add(const LoginSubmitted());
        },
        expect: () => const <LoginState>[
          LoginState(email: Email.dirty(mockEmail)),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
          ),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
            status: FormzSubmissionStatus.success,
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginFailure] when logIn fails',
        setUp: () {
          when(
            () => authenticationRepository.logIn(
              email: mockEmail,
              password: mockPassword,
            ),
          ).thenThrow(Exception('oops'));
        },
        build: buildBloc,
        act: (bloc) {
          bloc
            ..add(const LoginUsernameChanged(mockEmail))
            ..add(const LoginPasswordChanged(mockPassword))
            ..add(const LoginSubmitted());
        },
        expect: () => const <LoginState>[
          LoginState(
            email: Email.dirty(mockEmail),
          ),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
          ),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
            status: FormzSubmissionStatus.inProgress,
          ),
          LoginState(
            email: Email.dirty(mockEmail),
            password: Password.dirty(mockPassword),
            isValid: true,
            status: FormzSubmissionStatus.failure,
          ),
        ],
      );
    });
  });
}
