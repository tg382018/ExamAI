import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class ExamDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ExamDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, int?> _answers = {};
  Timer? _timer;
  int _secondsRemaining = 0;
  DateTime? _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer(int minutes) {
    if (_timer != null) return;
    _secondsRemaining = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _submit();
      }
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _submit() async {
    final questions = ref.read(examQuestionsProvider(widget.id)).value;
    if (questions == null) return;

    final answerList = questions.map((q) => {
      'questionId': q.id,
      'selectedOption': _answers[q.id],
    }).toList();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final api = ref.read(apiServiceProvider);
      final result = await api.submitAttempt(widget.id, answerList, _startedAt!);
      
      if (mounted) {
        Navigator.pop(context); // Close loading
        context.pushReplacement('/my-exams/score/${result['attemptId']}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examDetailProvider(widget.id));
    final questionsAsync = ref.watch(examQuestionsProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: examAsync.when(
          data: (exam) {
            _startTimer(exam.durationMin);
            return Text(exam.title);
          },
          loading: () => const Text('Yükleniyor...'),
          error: (_, __) => const Text('Hata'),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  color: _secondsRemaining < 60 ? Colors.red : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: examAsync.when(
        data: (exam) => questionsAsync.when(
          data: (questions) => Column(
            children: [
              LinearProgressIndicator(
                value: (questions.isEmpty) ? 0 : (_currentIndex + 1) / questions.length,
                backgroundColor: Colors.white10,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return _QuestionView(
                      question: q,
                      index: index,
                      total: questions.length,
                      selectedOption: _answers[q.id],
                      onSelect: (opt) => setState(() => _answers[q.id] = opt),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text('Geri'),
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentIndex < questions.length - 1
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : _submit,
                        child: Text(_currentIndex < questions.length - 1 ? 'Sonraki' : 'Sınavı Bitir'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Hata: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class _QuestionView extends StatelessWidget {
  final Question question;
  final int index;
  final int total;
  final int? selectedOption;
  final Function(int) onSelect;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    this.selectedOption,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${index + 1} / $total',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            question.text,
            style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          ...List.generate(question.options.length, (i) {
            final isSelected = selectedOption == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          question.options[i].substring(3), // Skip "A) "
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
