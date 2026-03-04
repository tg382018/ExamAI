import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

class AuthNotifier extends StateNotifier<User?> {
  final ApiService _api;
  AuthNotifier(this._api) : super(null);

  Future<void> login(String email, String password) async {
    final data = await _api.login(email, password);
    state = User.fromJson(data['user']);
  }

  Future<void> register(String email, String password, String name) async {
    final data = await _api.register(email, password, name);
    state = User.fromJson(data['user']);
  }

  void logout() {
    state = null;
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
    // Return examId or more info if needed
    return await _api.confirmExam(plan, prompt);
  }
}

final examDetailProvider = FutureProvider.family<Exam, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.getExamDetail(id);
  return Exam.fromJson(data);
});

final examQuestionsProvider = FutureProvider.family<List<Question>, String>((ref, id) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.getExamDetail(id);
  final List questions = data['questions'] ?? [];
  return questions.map((q) => Question.fromJson(q)).toList();
});
