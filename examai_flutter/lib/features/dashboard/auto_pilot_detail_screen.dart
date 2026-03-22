import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../exam_detail/exam_detail_screen.dart';

class AutoPilotDetailScreen extends ConsumerStatefulWidget {
  final AutoPilotConfig config;

  const AutoPilotDetailScreen({super.key, required this.config});

  @override
  ConsumerState<AutoPilotDetailScreen> createState() =>
      _AutoPilotDetailScreenState();
}

class _AutoPilotDetailScreenState extends ConsumerState<AutoPilotDetailScreen> {
  late AutoPilotConfig _config;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  Future<void> _toggleActive() async {
    setState(() => _isLoading = true);
    try {
      final updated = AutoPilotConfig(
        id: _config.id,
        isActive: !_config.isActive,
        frequency: _config.frequency,
        time: _config.time,
        dayOfWeek: _config.dayOfWeek,
        topic: _config.topic,
        subtopic: _config.subtopic,
        level: _config.level,
        questionCount: _config.questionCount,
        type: _config.type,
        prompt: _config.prompt,
        isPromptTab: _config.isPromptTab,
        language: _config.language,
        updatedAt: DateTime.now(),
        title: _config.title,
      );

      final api = ref.read(apiServiceProvider);
      final saved = await api.saveAutoPilotConfig(updated.toJson());
      setState(() {
        _config = AutoPilotConfig.fromJson(saved);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_config.isActive ? 'Aktif Edildi' : 'Pasif Edildi'),
          backgroundColor: _config.isActive ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sil?'),
        content: const Text(
            'Bu otomatik pilot talimatını silmek istediğinize emin misiniz? Geçmiş sınavlar silinmez.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final api = ref.read(apiServiceProvider);
        await api.deleteAutoPilotConfig(_config.id);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter exams from provider that belong to this config
    final exams = ref
        .watch(examsProvider)
        .where((e) => e.autoPilotConfigId == _config.id)
        .toList();
    exams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_config.title ?? _config.topic ?? 'Otomatik Pilot',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: _isLoading ? null : _delete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(isDark),
                  const SizedBox(height: 24),
                  _buildSettingsCard(isDark),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Üretilen Sınav Geçmişi',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${exams.length} Sınav',
                        style: GoogleFonts.outfit(
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (exams.isEmpty)
                    _buildEmptyHistory(isDark)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exams.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _buildExamCard(exams[index], isDark),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _config.isActive
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: (_config.isActive ? const Color(0xFF10B981) : Colors.orange)
                .withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  (_config.isActive ? const Color(0xFF10B981) : Colors.orange)
                      .withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _config.isActive ? Icons.check_circle : Icons.pause_circle_filled,
              color: _config.isActive ? const Color(0xFF10B981) : Colors.orange,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _config.isActive ? 'Talimat Aktif' : 'Talimat Duraklatıldı',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _config.isActive
                        ? const Color(0xFF10B981)
                        : Colors.orange,
                  ),
                ),
                Text(
                  _config.frequency == 'daily'
                      ? 'Her gün saat ${_config.time}\'da'
                      : 'Haftalık planlı',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _config.isActive,
            onChanged: (_) => _toggleActive(),
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yapılandırma',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildInfoRow(
              Icons.topic, 'Konu', _config.topic ?? 'Belirtilmedi', isDark),
          _buildInfoRow(Icons.help_outline, 'Soru Sayısı',
              '${_config.questionCount} Soru', isDark),
          _buildInfoRow(
              Icons.timer, 'Sıklık', _config.frequency.toUpperCase(), isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6366F1).withOpacity(0.7)),
          const SizedBox(width: 12),
          Text('$label:',
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white60 : Colors.black54)),
          const Spacer(),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildExamCard(Exam exam, bool isDark) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExamDetailScreen(id: exam.id),
        ),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined,
                  color: Color(0xFF6366F1), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('d MMMM yyyy, HH:mm').format(exam.createdAt),
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(Icons.history,
              size: 48, color: isDark ? Colors.white12 : Colors.black12),
          const SizedBox(height: 12),
          Text(
            'Henüz otomatik sınav üretilmedi.',
            style: GoogleFonts.outfit(
                color: isDark ? Colors.white38 : Colors.black38),
          ),
        ],
      ),
    );
  }
}
