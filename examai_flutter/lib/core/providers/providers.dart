import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/preferences_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final preferencesServiceProvider = Provider((ref) => PreferencesService());

final onboardingSeenProvider = FutureProvider<bool>((ref) {
  return ref.watch(preferencesServiceProvider).hasSeenOnboarding();
});

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;
  AuthNotifier(this._api) : super(AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.login(email, password);
      state = state.copyWith(
        user: User.fromJson(data['user']),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _api.register(email, password, name);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verify(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.verifyEmail(email, code);
      state = state.copyWith(
        user: User.fromJson(data['user']),
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resendCode(String email) async {
    try {
      await _api.resendVerification(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final examsProvider = StateNotifierProvider<ExamsNotifier, List<Exam>>((ref) {
  return ExamsNotifier(ref.read(apiServiceProvider));
});

class ExamsNotifier extends StateNotifier<List<Exam>> {
  final ApiService _api;
  ExamsNotifier(this._api) : super([]);

  Future<void> fetchExams() async {
    final data = await _api.getExams();
    state = data.map((e) => Exam.fromJson(e)).toList();
  }

  Future<String> proposeExam(String prompt) async {
    final plan = await _api.getDraftPlan(prompt);
    return await _api.confirmExam(plan, prompt);
  }
}

final examDetailProvider = FutureProvider.family<Exam, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.getExamDetail(id);
  return Exam.fromJson(data);
});

final examQuestionsProvider =
    FutureProvider.family<List<Question>, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.getExamDetail(id);
  final List questions = data['questions'] ?? [];
  return questions.map((q) => Question.fromJson(q)).toList();
});
