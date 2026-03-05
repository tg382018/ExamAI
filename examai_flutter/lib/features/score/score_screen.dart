import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../solutions/solutions_screen.dart';
import '../ai_summary/ai_summary_screen.dart';

class ScoreScreen extends ConsumerWidget {
  final String attemptId;
  const ScoreScreen({super.key, required this.attemptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sonuç'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/my-exams'),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: api.getAttempt(attemptId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final attempt = Attempt.fromJson(data);
          final score = attempt.score;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: score / 100,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '%${score.toInt()}',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Text('Başarı',
                          style: TextStyle(color: Colors.white60)),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: Colors.white10,
                  progressColor: _getScoreColor(score),
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ResultStat(
                        label: 'Doğru',
                        value: '${attempt.correctCount}',
                        color: Colors.green),
                    _ResultStat(
                        label: 'Yanlış',
                        value: '${attempt.wrongCount}',
                        color: Colors.red),
                    _ResultStat(
                        label: 'Boş',
                        value: '${attempt.emptyCount}',
                        color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 48),
                _ActionCard(
                  icon: Icons.lightbulb_outline,
                  title: 'Çözümleri Gör',
                  subtitle:
                      'Soruların doğru cevaplarını ve çözümlerini incele.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            SolutionsScreen(examId: attempt.examId)),
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  icon: Icons.auto_awesome,
                  title: 'AI Özeti',
                  subtitle: 'Yapay zeka senin için sınav konularını özetledi.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AISummaryScreen(examId: attempt.examId)),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.go('/my-exams'),
                  child: const Text('Ana Sayfaya Dön'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 14)),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white60)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white24),
            ],
          ),
        ),
      ),
    );
  }
}
