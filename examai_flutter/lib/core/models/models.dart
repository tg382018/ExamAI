import 'package:json_annotation/json_annotation.dart';

enum ExamStatus { QUEUED, GENERATING, READY, FAILED }

class Exam {
  final String id;
  final String title;
  final String prompt;
  final ExamStatus status;
  final int durationMin;
  final int questionCount;
  final String difficulty;
  final String? aiSummary;
  final DateTime createdAt;
  final double? lastScore;

  Exam({
    required this.id,
    required this.title,
    required this.prompt,
    required this.status,
    required this.durationMin,
    required this.questionCount,
    required this.difficulty,
    this.aiSummary,
    required this.createdAt,
    this.lastScore,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      title: json['title'],
      prompt: json['prompt'] ?? '',
      status: ExamStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExamStatus.QUEUED,
      ),
      durationMin: json['durationMin'] ?? 0,
      questionCount: json['questionCount'] ?? 0,
      difficulty: json['difficulty'] ?? 'mixed',
      aiSummary: json['aiSummary'],
      createdAt: DateTime.parse(json['createdAt']),
      lastScore: json['lastScore']?.toDouble(),
    );
  }
}

class Question {
  final String id;
  final int orderIndex;
  final String text;
  final List<String> options;
  final int? correctOption;
  final String? explanation;
  final String difficulty;
  final String topicTag;

  Question({
    required this.id,
    required this.orderIndex,
    required this.text,
    required this.options,
    this.correctOption,
    this.explanation,
    required this.difficulty,
    required this.topicTag,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      orderIndex: json['orderIndex'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctOption: json['correctOption'],
      explanation: json['explanation'],
      difficulty: json['difficulty'],
      topicTag: json['topicTag'],
    );
  }
}

class Attempt {
  final String id;
  final String examId;
  final double score;
  final int correctCount;
  final int wrongCount;
  final int emptyCount;
  final DateTime finishedAt;
  final String? examTitle;

  Attempt({
    required this.id,
    required this.examId,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.finishedAt,
    this.examTitle,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      id: json['id'],
      examId: json['examId'],
      score: (json['score'] ?? 0).toDouble(),
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
      emptyCount: json['emptyCount'] ?? 0,
      finishedAt: DateTime.parse(json['finishedAt']),
      examTitle: json['exam']?['title'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;

  User({required this.id, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
    );
  }
}
