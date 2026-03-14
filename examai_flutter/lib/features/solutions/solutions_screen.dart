import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/math_text.dart';

class SolutionsScreen extends ConsumerWidget {
  final String examId;
  final List<dynamic>? userAnswers;
  const SolutionsScreen({super.key, required this.examId, this.userAnswers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Çözümler')),
      body: FutureBuilder<List<dynamic>>(
        future: api.getSolutions(examId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final questions =
              snapshot.data!.map((q) => Question.fromJson(q)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              // Find user answer for this specific question
              int? userAnswer;
              if (userAnswers != null) {
                final ans = userAnswers!.firstWhere(
                  (a) => a['questionId'] == q.id,
                  orElse: () => null,
                );
                userAnswer = ans?['selectedOption'];
              }

              return _SolutionCard(
                question: q,
                index: index,
                userAnswer: userAnswer,
              );
            },
          );
        },
      ),
    );
  }
}

class _SolutionCard extends StatefulWidget {
  final Question question;
  final int index;
  final int? userAnswer;
  const _SolutionCard({
    required this.question,
    required this.index,
    this.userAnswer,
  });

  @override
  State<_SolutionCard> createState() => _SolutionCardState();
}

class _SolutionCardState extends State<_SolutionCard> {
  bool _isExpanded = false;

  String _cleanOption(String option) {
    // Robustly remove prefixes like "A) ", "A. ", "A - "
    final regex = RegExp(r'^[A-E][).:\-\s]+');
    return option.replaceFirst(regex, '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isCorrect = widget.userAnswer == widget.question.correctOption;
    final bool isAnswered = widget.userAnswer != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.question.asciiArt != null &&
                            widget.question.asciiArt!.isNotEmpty) ...[
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Text(
                                widget.question.asciiArt!,
                                style: GoogleFonts.firaMono(
                                  fontSize: 12,
                                  height: 1.2,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        MathText(
                          widget.question.text,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (!isCorrect && isAnswered)
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                  if (isCorrect)
                    const Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white24,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                if (isAnswered) ...[
                  const Text('Senin Cevabın:',
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isCorrect ? Colors.green : Colors.red)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: (isCorrect ? Colors.green : Colors.red)
                              .withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(isCorrect ? Icons.check : Icons.close,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MathText(
                            _cleanOption(
                                widget.question.options[widget.userAnswer!]),
                            style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text('Doğru Cevap:',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MathText(
                          _cleanOption(widget.question
                              .options[widget.question.correctOption!]),
                          style: const TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Çözüm Açıklaması:',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 8),
                MathText(
                  widget.question.explanation ?? 'Açıklama mevcut değil.',
                  style: const TextStyle(height: 1.5, color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
