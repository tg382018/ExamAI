import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/math_text.dart';

class ExamDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const ExamDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, dynamic> _answers = {};
  final Map<String, TextEditingController> _controllers = {};
  Timer? _timer;
  int _secondsRemaining = 0;
  DateTime? _startedAt;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer(int minutes) {
    if (_timer != null || _isTimeUp) return;
    _secondsRemaining = minutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        if (mounted) {
          setState(() => _isTimeUp = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Süre Doldu! Sınavınız otomatik olarak gönderiliyor...'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          _submit();
        }
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

    final answerList = questions.map((q) {
      dynamic val = _answers[q.id];
      if (q.type == QuestionType.open_ended) {
        val = _controllers[q.id]?.text;
      }
      return {
        'questionId': q.id,
        'selectedOption': val,
      };
    }).toList();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final api = ref.read(apiServiceProvider);
      final result =
          await api.submitAttempt(widget.id, answerList, _startedAt!);

      if (mounted) {
        Navigator.pop(context); // Close loading
        context.pushReplacement('/my-exams/score/${result['attemptId']}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
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
            final durationStr =
                GoRouterState.of(context).uri.queryParameters['duration'];
            final duration = durationStr != null
                ? int.tryParse(durationStr) ?? exam.durationMin
                : (exam.durationMin > 0 ? exam.durationMin : 10);
            _startTimer(duration);
            return Text(exam.title);
          },
          loading: () => const Text('Yükleniyor...'),
          error: (_, __) => const Text('Hata'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldPop = await _showExitConfirmation();
            if (shouldPop && mounted) {
              context.pop();
            }
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatTime(_secondsRemaining),
                style: TextStyle(
                  color: _secondsRemaining < 60
                      ? Colors.red
                      : Theme.of(context).appBarTheme.foregroundColor ??
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldPop = await _showExitConfirmation();
          if (shouldPop && mounted) {
            context.pop();
          }
        },
        child: examAsync.when(
          data: (exam) => questionsAsync.when(
            data: (questions) => Column(
              children: [
                LinearProgressIndicator(
                  value: (questions.isEmpty)
                      ? 0
                      : (_currentIndex + 1) / questions.length,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      if (q.type == QuestionType.open_ended &&
                          !_controllers.containsKey(q.id)) {
                        _controllers[q.id] = TextEditingController();
                      }
                      return IgnorePointer(
                        ignoring: _isTimeUp,
                        child: _QuestionView(
                          question: q,
                          index: index,
                          total: questions.length,
                          selectedValue: _answers[q.id],
                          controller: _controllers[q.id],
                          onSelect: (opt) =>
                              setState(() => _answers[q.id] = opt),
                        ),
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
                          onPressed: _isTimeUp
                              ? null
                              : (_currentIndex < questions.length - 1
                                  ? () => _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      )
                                  : _submit),
                          child: Text(_currentIndex < questions.length - 1
                              ? 'Sonraki'
                              : 'Sınavı Bitir'),
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
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sınavdan Çıkılsın mı?'),
        content: const Text(
            'Çıkmak istediğinizden emin misiniz? Sınavı bitirmeden çıkarsanız ilerlemeniz kaydedilmeyecek ve başarı puanınız 0 sayılacaktır.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Devam Et'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sınavı Terket'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _QuestionView extends StatelessWidget {
  final Question question;
  final int index;
  final int total;
  final dynamic selectedValue;
  final TextEditingController? controller;
  final Function(dynamic) onSelect;

  const _QuestionView({
    required this.question,
    required this.index,
    required this.total,
    this.selectedValue,
    this.controller,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soru ${index + 1} / $total',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (question.asciiArt != null && question.asciiArt!.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: Text(
                  question.asciiArt!,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    height: 1.2,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          MathText(
            question.text,
            style: const TextStyle(
                fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          if (question.type == QuestionType.open_ended) ...[
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              onChanged: (val) => onSelect(val),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Cevabınızı buraya yazın...',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 2),
                ),
              ),
              maxLines: 6,
              minLines: 3,
            ),
          ] else if (question.type == QuestionType.true_false) ...[
            Row(
              children: [
                Expanded(
                  child: _buildSimpleOption(context, 0, 'Doğru',
                      selectedValue == 0, () => onSelect(0)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSimpleOption(context, 1, 'Yanlış',
                      selectedValue == 1, () => onSelect(1)),
                ),
              ],
            ),
          ] else ...[
            ...List.generate(question.options.length, (i) {
              final isSelected = selectedValue == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MathText(
                            question.options[i],
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
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
        ],
      ),
    );
  }

  Widget _buildSimpleOption(BuildContext context, int index, String label,
      bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
