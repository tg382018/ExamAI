import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class SolutionsScreen extends ConsumerWidget {
  final String examId;
  const SolutionsScreen({super.key, required this.examId});

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

          final questions = snapshot.data!.map((q) => Question.fromJson(q)).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return _SolutionCard(question: q, index: index);
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
  const _SolutionCard({required this.question, required this.index});

  @override
  State<_SolutionCard> createState() => _SolutionCardState();
}

class _SolutionCardState extends State<_SolutionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
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
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                    child: Text(
                      widget.question.text,
                      maxLines: _isExpanded ? null : 2,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white24,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 20),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                const Text('Doğru Cevap:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.question.options[widget.question.correctOption!],
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Çözüm Açıklaması:', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 8),
                Text(
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
