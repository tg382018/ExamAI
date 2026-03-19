import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/widgets.dart';

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
      final hasPending = exams.any((e) =>
          e.status == ExamStatus.queued || e.status == ExamStatus.generating);
      if (hasPending) {
        ref.read(examsProvider.notifier).fetchExams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exams = ref.watch(examsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myExamsTitle),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  Text(l10n.myExamsEmpty,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
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
    );
  }
}

class _ExamCard extends StatelessWidget {
  final Exam exam;
  const _ExamCard({required this.exam});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: exam.status == ExamStatus.ready
            ? () => context.push('/my-exams/${exam.id}')
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      exam.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: exam.status == ExamStatus.ready
                                ? onSurface
                                : onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                  ),
                  StatusChip(status: exam.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: onSurface.withValues(alpha: 0.38)),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(exam.createdAt),
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38), fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.question_answer,
                      size: 14, color: onSurface.withValues(alpha: 0.38)),
                  const SizedBox(width: 4),
                  Text(
                    l10n.examQuestionCount(exam.questionCount),
                    style: TextStyle(
                        color: onSurface.withValues(alpha: 0.38), fontSize: 12),
                  ),
                ],
              ),
              if (exam.lastScore != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.examLastScore,
                          style: TextStyle(
                              color: onSurface.withValues(alpha: 0.6),
                              fontSize: 13)),
                      const SizedBox(width: 4),
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
