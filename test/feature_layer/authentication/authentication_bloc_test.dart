import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_flow/domain_layer/domain_layer.dart';
import 'package:login_flow/feature_layer/authentication/authentication.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthenticationRepository extends Mock
    implements AuthenticationRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  const user = User('id');
  late AuthenticationRepository authenticationRepository;
  late UserRepository userRepository;

  setUp(() {
    authenticationRepository = MockAuthenticationRepository();
    userRepository = MockUserRepository();
    when(
      () => authenticationRepository.status,
    ).thenAnswer((_) => const Stream.empty());
  });

  AuthenticationBloc buildBloc() {
    return AuthenticationBloc(
      authenticationRepository: authenticationRepository,
      userRepository: userRepository,
    );
  }

  group('AuthenticationBloc', () {
    test('initial state is AuthenticationState.unknown', () {
      expect(buildBloc().state, const AuthenticationState.unknown());
    });

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unauthenticated] when status is unauthenticated',
      setUp: () {
        when(() => authenticationRepository.status).thenAnswer(
          (_) => Stream.value(AuthenticationStatus.unauthenticated),
        );
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.unauthenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [authenticated] when status is authenticated',
      setUp: () {
        when(() => authenticationRepository.status).thenAnswer(
          (_) => Stream.value(AuthenticationStatus.authenticated),
        );
        when(() => userRepository.getUser()).thenAnswer((_) async => user);
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.authenticated(user),
      ],
    );
  });

  group('AuthenticationStatusChanged', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [authenticated] when status is authenticated',
      setUp: () {
        when(
          () => authenticationRepository.status,
        ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
        when(() => userRepository.getUser()).thenAnswer((_) async => user);
      },
      build: buildBloc,
      expect: () => const [
        AuthenticationState.authenticated(user),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unauthenticated] when status is unauthenticated',
      setUp: () {
        when(
          () => authenticationRepository.status,
        ).thenAnswer((_) => Stream.value(AuthenticationStatus.unauthenticated));
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.unauthenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unauthenticated] when status is authenticated but getUser fails',
      setUp: () {
        when(
          () => authenticationRepository.status,
        ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
        when(() => userRepository.getUser()).thenThrow(Exception('oops'));
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.unauthenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unauthenticated] when status is authenticated '
      'but getUser returns null',
      setUp: () {
        when(
          () => authenticationRepository.status,
        ).thenAnswer((_) => Stream.value(AuthenticationStatus.authenticated));
        when(() => userRepository.getUser()).thenAnswer((_) async => null);
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.unauthenticated(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'emits [unknown] when status is unknown',
      setUp: () {
        when(
          () => authenticationRepository.status,
        ).thenAnswer((_) => Stream.value(AuthenticationStatus.unknown));
      },
      build: buildBloc,
      expect: () => const <AuthenticationState>[
        AuthenticationState.unknown(),
      ],
    );
  });

  group('AuthenticationLogoutRequested', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'calls logOut on authenticationRepository '
      'when AuthenticationLogoutRequested is added',
      build: buildBloc,
      act: (bloc) => bloc.add(AuthenticationLogoutRequested()),
      verify: (_) {
        verify(() => authenticationRepository.logOut()).called(1);
      },
    );
  });
}
