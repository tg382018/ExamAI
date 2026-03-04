import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _promptController = TextEditingController();
  bool _loading = false;

  void _submit() async {
    if (_promptController.text.isEmpty) return;
    
    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final plan = await api.getDraftPlan(_promptController.text);
      
      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan['title'] ?? 'Sınav Planı', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _PlanInfoRow(icon: Icons.question_answer, label: '${plan['questionCount']} Soru'),
              _PlanInfoRow(icon: Icons.timer, label: '${plan['durationMin']} Dakika'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await api.confirmExam(plan, _promptController.text);
                  if (context.mounted) {
                    context.pop(); // Close bottom sheet
                    context.pop(); // Go back to my exams
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sınav hazırlanıyor, hazır olunca bildirim atacağız!')),
                    );
                  }
                },
                child: const Text('Tamam, Hazırla'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Center(child: Text('Vazgeç')),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Sınav')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ne üzerine sınav olacaksın?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Örn: 11. sınıf matematik üslü sayılar sınavı', style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 24),
            TextField(
              controller: _promptController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Talebinizi buraya yazın...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Planı Gör'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlanInfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
