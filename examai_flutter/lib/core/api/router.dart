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
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/score/score_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/subscription_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
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
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/my-exams',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'list',
            builder: (context, state) => const MyExamsScreen(),
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
      if (onboardingSeen == null) return null;

      // Read auth state inside redirect instead of watching at provider level
      // This prevents the entire GoRouter from being recreated on auth changes
      final authState = ref.read(authProvider);

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
      if (isAtOnboarding || (!isAuthPath && authState.user == null)) {
        return '/login';
      }

      return null;
    },
  );
});
