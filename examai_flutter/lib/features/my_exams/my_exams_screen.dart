import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';

class MyExamsScreen extends ConsumerStatefulWidget {
  const MyExamsScreen({super.key});

  @override
  ConsumerState<MyExamsScreen> createState() => _MyExamsScreenState();
}

class _MyExamsScreenState extends ConsumerState<MyExamsScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examsProvider.notifier).fetchExams());
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final exams = ref.read(examsProvider);
      final hasPending = exams.any((e) => e.status == ExamStatus.QUEUED || e.status == ExamStatus.GENERATING);
      if (hasPending) {
        ref.read(examsProvider.notifier).fetchExams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exams = ref.watch(examsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınavlarım'),
        actions: [
          IconButton(
            onPressed: () => ref.read(examsProvider.notifier).fetchExams(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: exams.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: Main_axisAlignment.center,
                children: [
                  const Icon(Icons.note_alt_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text('Henüz hiç sınavın yok.', style: TextStyle(color: Colors.white60)),
                  TextButton(
                    onPressed: () => context.push('/my-exams/create'),
                    child: const Text('İlk Sınavını Oluştur'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(examsProvider.notifier).fetchExams(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  return _ExamCard(exam: exam);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/my-exams/create'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Sınav'),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: exam.status == ExamStatus.READY
            ? () => context.push('/my-exams/${exam.id}')
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: Main_axisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: exam.status == ExamStatus.READY ? Colors.white : Colors.white54,
                          ),
                    ),
                  ),
                  _StatusChip(status: exam.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(exam.createdAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.question_answer, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    '${exam.questionCount} Soru',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              if (exam.lastScore != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: Main_axisAlignment.min,
                    children: [
                      const Text('Son Skor: ', style: TextStyle(color: Colors.white60, fontSize: 13)),
                      Text(
                        '%${exam.lastScore}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ExamStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    bool loading = false;

    switch (status) {
      case ExamStatus.QUEUED:
        color = Colors.orange;
        text = 'Sırada';
        loading = true;
        break;
      case ExamStatus.GENERATING:
        color = Colors.blue;
        text = 'Hazırlanıyor';
        loading = true;
        break;
      case ExamStatus.READY:
        color = Colors.green;
        text = 'Hazır';
        break;
      case ExamStatus.FAILED:
        color = Colors.red;
        text = 'Hata';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: Main_axisAlignment.min,
        children: [
          if (loading) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
            const SizedBox(width: 6),
          ],
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
