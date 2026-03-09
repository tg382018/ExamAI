import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/create/create_screen.dart';
import '../../features/exam_detail/exam_detail_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/score/score_screen.dart';
import '../../features/settings/settings_screen.dart';

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
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
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
      final onboardingSeen = onboardingSeenAsync.valueOrNull;
      // If onboarding status is not yet loaded, don't redirect yet
      if (onboardingSeen == null) return null;

      final isAtOnboarding = state.matchedLocation == '/onboarding';
      final isAuthPath = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email';

      // 1. If onboarding hasn't been seen, force them there
      if (!onboardingSeen) {
        return isAtOnboarding ? null : '/onboarding';
      }

      // 2. If user is logged in
      if (authState.user != null) {
        // Don't allow them to stay on auth/onboarding screens
        if (isAuthPath || isAtOnboarding) {
          return '/my-exams';
        }
        return null;
      }

      // 3. If user is NOT logged in
      // If they are at onboarding (which they've seen), or at a protected path, go to login
      if (isAtOnboarding || (!isAuthPath && authState.user == null)) {
        return '/login';
      }

      return null;
    },
  );
});
