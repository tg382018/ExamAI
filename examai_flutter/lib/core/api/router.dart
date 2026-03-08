import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/create/create_screen.dart';
import '../../features/my_exams/my_exams_screen.dart';
import '../../features/exam_detail/exam_detail_screen.dart';
import '../../features/score/score_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final onboardingSeenAsync = ref.watch(onboardingSeenProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final email = state.extra as String;
          return VerifyEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/my-exams',
        builder: (context, state) => const MyExamsScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreateScreen(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                ExamDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'score/:attemptId',
            builder: (context, state) =>
                ScoreScreen(attemptId: state.pathParameters['attemptId']!),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Wait for onboarding status to be loaded
      final onboardingSeen = onboardingSeenAsync.valueOrNull;
      if (onboardingSeen == null) return null;

      final isAtOnboarding = state.matchedLocation == '/onboarding';

      if (!onboardingSeen) {
        return isAtOnboarding ? null : '/onboarding';
      }

      // If they have seen onboarding, don't let them go back there
      if (isAtOnboarding) {
        return authState == null ? '/register' : '/my-exams';
      }

      final isAuthPath = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email';
      if (authState == null) return isAuthPath ? null : '/login';
      if (isAuthPath) return '/my-exams';
      return null;
    },
  );
});
