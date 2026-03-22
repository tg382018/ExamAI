import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl:
        Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle logic to logout or clear token
        }
        return handler.next(e);
      },
    ));
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio
        .post('/auth/login', data: {'email': email, 'password': password});
    if (res.data['token'] != null) {
      await _storage.write(key: 'token', value: res.data['token']);
    }
    return res.data;
  }

  Future<Map<String, dynamic>> register(
      String email, String password, String name) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
    // Token is no longer returned on register, only after verification
    return res.data;
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final res =
        await _dio.post('/auth/verify', data: {'email': email, 'code': code});
    if (res.data['token'] != null) {
      await _storage.write(key: 'token', value: res.data['token']);
    }
    return res.data;
  }

  Future<void> resendVerification(String email) async {
    await _dio.post('/auth/resend-verification', data: {'email': email});
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  // Exams
  Future<Map<String, dynamic>> getDraftPlan(String prompt,
      {File? attachment}) async {
    if (attachment != null) {
      final formData = FormData.fromMap({
        'prompt': prompt,
        'attachment': await MultipartFile.fromFile(
          attachment.path,
          filename: attachment.path.split('/').last,
        ),
      });
      final res = await _dio.post('/exam/draft',
          data: formData,
          options: Options(receiveTimeout: const Duration(seconds: 60)));
      return res.data;
    }
    final res = await _dio.post('/exam/draft', data: {'prompt': prompt});
    return {'suggested': res.data['suggested']};
  }

  Future<String> confirmExam(Map<String, dynamic> plan, String prompt,
      {String? fileBase64, String? fileMime, bool isAuto = false}) async {
    final data = {
      ...plan,
      'prompt': prompt,
      if (fileBase64 != null) 'fileBase64': fileBase64,
      if (fileMime != null) 'fileMime': fileMime,
      'isAuto': isAuto,
    };
    final res = await _dio.post('/exam', data: data);
    return res.data['examId'];
  }

  Future<List<dynamic>> getExams() async {
    final res = await _dio.get('/exams');
    return res.data;
  }

  Future<Map<String, dynamic>> getExamDetail(String id) async {
    final res = await _dio.get('/exams/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> submitAttempt(String examId,
      List<Map<String, dynamic>> answers, DateTime startedAt) async {
    final res = await _dio.post('/exams/$examId/attempts', data: {
      'answers': answers,
      'startedAt': startedAt.toIso8601String(),
    });
    return res.data;
  }

  Future<Map<String, dynamic>> getAttempt(String attemptId) async {
    final res = await _dio.get('/exams/attempts/$attemptId');
    return res.data;
  }

  Future<List<dynamic>> getSolutions(String examId) async {
    final res = await _dio.get('/exams/$examId/solutions');
    return res.data;
  }

  Future<String> getSummary(String examId) async {
    final res = await _dio.get('/exams/$examId/summary');
    return res.data['summary'];
  }

  // Devices
  Future<void> registerDeviceToken(String token, String platform) async {
    await _dio
        .post('/device-token', data: {'token': token, 'platform': platform});
  }

  // Auto-Pilot
  Future<List<dynamic>> getAutoPilotConfigs() async {
    final res = await _dio.get('/auto-pilot');
    return res.data;
  }

  Future<Map<String, dynamic>> saveAutoPilotConfig(
      Map<String, dynamic> config) async {
    final res = await _dio.post('/auto-pilot', data: config);
    return res.data;
  }

  Future<void> deleteAutoPilotConfig(String id) async {
    await _dio.delete('/auto-pilot/$id');
  }
}
