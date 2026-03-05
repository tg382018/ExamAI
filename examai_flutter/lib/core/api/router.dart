import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/create/create_screen.dart';
import '../../features/my_exams/my_exams_screen.dart';
import '../../features/exam_detail/exam_detail_screen.dart';
import '../../features/score/score_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: authState == null ? '/login' : '/my-exams',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (authState == null) return isLoggingIn ? null : '/login';
      if (isLoggingIn) return '/my-exams';
      return null;
    },
  );
});
