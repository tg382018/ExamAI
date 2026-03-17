enum ExamStatus { queued, generating, ready, failed }

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
        (e) => e.name == json['status'].toString().toLowerCase(),
        orElse: () => ExamStatus.queued,
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

enum QuestionType { multiple_choice, true_false, open_ended }

class Question {
  final String id;
  final QuestionType type;
  final int orderIndex;
  final String text;
  final List<String> options;
  final int? correctOption;
  final String? correctAnswer;
  final String? explanation;
  final String difficulty;
  final String topicTag;
  final String? asciiArt;

  Question({
    required this.id,
    required this.type,
    required this.orderIndex,
    required this.text,
    required this.options,
    this.correctOption,
    this.correctAnswer,
    this.explanation,
    required this.difficulty,
    required this.topicTag,
    this.asciiArt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type']?.toString().toLowerCase(),
        orElse: () => QuestionType.multiple_choice,
      ),
      orderIndex: json['orderIndex'] ?? 0,
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOption: json['correctOption'],
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
      difficulty: json['difficulty'] ?? 'mixed',
      topicTag: json['topicTag'] ?? '',
      asciiArt: json['asciiArt'],
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
  final List<dynamic>? answers;

  Attempt({
    required this.id,
    required this.examId,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.emptyCount,
    required this.finishedAt,
    this.examTitle,
    this.answers,
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
      answers: json['answers'],
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
