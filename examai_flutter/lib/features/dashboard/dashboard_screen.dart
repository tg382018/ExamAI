import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'topic_data.dart';
import 'auto_pilot_detail_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Theme-aware color helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  final _promptController = TextEditingController();
  final _subtopicController = TextEditingController();
  bool _loading = false;
  bool _isPromptTab = true;
  File? _attachedFile;
  String? _draftFileBase64;
  String? _draftFileMime;

  // Manual Create Filter states
  String _selectedLevel = 'High School';
  String _selectedTopic = '';
  int _selectedCount = 10;
  String _selectedType = 'Multiple Choice';
  final List<String> _subtopics = [];
  String _selectedSubtopic = 'All';
  final _subtopicFocusNode = FocusNode();

  Map<String, List<String>> get _topicData =>
      getLocalizedTopicData(Localizations.localeOf(context).languageCode);

  // Auto-Pilot states
  String _autoFreq = 'Passive';
  TimeOfDay _autoTime = const TimeOfDay(hour: 09, minute: 00);
  int? _autoDay = 1;

  File? _autoAttachedFile;
  bool _autoIsPromptTab = true;
  String _autoLevel = 'University';
  String _autoTopic = '';
  String _autoSubtopic = 'All';
  int _autoCount = 10;
  String _autoType = 'Multiple Choice';
  final List<String> _autoSubtopics = [];
  final TextEditingController _autoPromptController = TextEditingController();
  final TextEditingController _autoSubtopicController = TextEditingController();
  final FocusNode _autoSubtopicFocusNode = FocusNode();
  List<AutoPilotConfig> _autoPilotConfigs = [];

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examsProvider.notifier).fetchExams());
    _fetchAutoPilotConfigs();
    _startPolling();
  }

  Future<void> _fetchAutoPilotConfigs() async {
    setState(() {});
    try {
      final api = ref.read(apiServiceProvider);
      final configs = await api.getAutoPilotConfigs();
      setState(() {
        _autoPilotConfigs =
            configs.map((c) => AutoPilotConfig.fromJson(c)).toList();
      });
    } catch (e) {
      debugPrint('[AutoPilot Fetch] Error: $e');
    } finally {
      setState(() {});
    }
  }

  Future<void> _saveAutoPilotConfig({bool showSnackbar = true}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final config = {
        'isActive': _autoFreq != 'Passive',
        'frequency': _autoFreq.toLowerCase(),
        'time':
            '${_autoTime.hour.toString().padLeft(2, '0')}:${_autoTime.minute.toString().padLeft(2, '0')}',
        'dayOfWeek': _autoFreq == 'Weekly' ? _autoDay : null,
        'topic': _autoTopic,
        'subtopic': _autoSubtopic == 'All' ? null : _autoSubtopic,
        'level': _autoLevel.toLowerCase(),
        'questionCount': _autoCount,
        'type': _autoType.toLowerCase().replaceAll(' ', '_'),
        'language': Localizations.localeOf(context).languageCode,
        'prompt': _autoPromptController.text,
        'isPromptTab': _autoIsPromptTab,
        'title': _autoIsPromptTab
            ? (_autoPromptController.text.length > 30
                ? _autoPromptController.text.substring(0, 30) + '...'
                : _autoPromptController.text)
            : '${_getLevelTitle(_autoLevel, l10n)} $_autoTopic',
      };

      final api = ref.read(apiServiceProvider);
      await api.saveAutoPilotConfig(config);
      await _fetchAutoPilotConfigs(); // Refresh the list

      if (mounted && showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Otomatik Sınav Talimatı Kaydedildi! ✨'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }

      // Reset creation state
      setState(() {
        _autoPromptController.clear();
        _autoTopic = _topicData.keys.first;
        _autoSubtopic = 'All';
        _autoSubtopics.clear();
        _autoAttachedFile = null;
      });
    } on DioException catch (e) {
      if (mounted) {
        if (e.response?.statusCode == 403) {
          final errorMsg = e.response?.data?['error'] ?? 'Limit uyarısı';
          _showUpgradeDialog(errorMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Hata: ${e.response?.data?['error'] ?? e.message}'),
                backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beklenmedik bir hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize topics if empty (happens on first load across different locales)
    if (_selectedTopic.isEmpty && _topicData.isNotEmpty) {
      _selectedTopic = _topicData.keys.first;
    }
    if (_autoTopic.isEmpty && _topicData.isNotEmpty) {
      _autoTopic = _topicData.keys.first;
    }

    // Ensure current selection is valid for the current localized data
    if (_selectedTopic.isNotEmpty && !_topicData.containsKey(_selectedTopic)) {
      _selectedTopic = _topicData.keys.first;
    }
    if (_autoTopic.isNotEmpty && !_topicData.containsKey(_autoTopic)) {
      _autoTopic = _topicData.keys.first;
    }

    // Ensure subtopics are valid
    final l10n = AppLocalizations.of(context)!;
    if (_selectedSubtopic != 'All' &&
        _selectedSubtopic != l10n.dashboardFilterSubtopicOther &&
        !(_topicData[_selectedTopic] ?? []).contains(_selectedSubtopic)) {
      _selectedSubtopic = 'All';
    }
    if (_autoSubtopic != 'All' &&
        _autoSubtopic != l10n.dashboardFilterSubtopicOther &&
        !(_topicData[_autoTopic] ?? []).contains(_autoSubtopic)) {
      _autoSubtopic = 'All';
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _subtopicController.dispose();
    _autoPromptController.dispose();
    _autoSubtopicController.dispose();
    _subtopicFocusNode.dispose();
    _autoSubtopicFocusNode.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      final exams = ref.read(examsProvider);
      final hasPending = exams.any((e) =>
          e.status == ExamStatus.queued || e.status == ExamStatus.generating);
      if (hasPending) {
        ref.read(examsProvider.notifier).fetchExams();
      }
    });
  }

  String _getLevelTitle(String level, AppLocalizations l10n) {
    switch (level) {
      case 'Elementary':
        return l10n.levelElementary;
      case 'Middle School':
        return l10n.levelMiddle;
      case 'High School':
        return l10n.levelHigh;
      case 'University':
        return l10n.levelUniversity;
      case 'College':
        return l10n.levelCollege;
      case 'Professional':
        return l10n.levelProfessional;
      default:
        return level;
    }
  }

  String _getTypeTitle(String type, AppLocalizations l10n) {
    switch (type) {
      case 'Multiple Choice':
        return l10n.typeMCQ;
      case 'Open Ended':
        return l10n.typeOpen;
      case 'True/False':
        return l10n.typeTF;
      case 'Mixed':
        return l10n.typeMixed;
      default:
        return type;
    }
  }

  void _showPlanDialog(Map<String, dynamic> plan, String finalPrompt,
      {String? fileBase64, String? fileMime, bool isAuto = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<dynamic> outline = plan['outline'] ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Sınav Taslağı Hazır! 🎯',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan['title'] ?? 'Yeni Sınav',
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      if (plan['description'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          plan['description'],
                          style: GoogleFonts.outfit(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 15,
                              height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildPlanTag(Icons.help_outline,
                              '${plan['questionCount']} Soru'),
                          const SizedBox(width: 12),
                          _buildPlanTag(
                              Icons.draw_outlined,
                              plan['needsAscii'] == true
                                  ? 'ASCII: Evet'
                                  : 'ASCII: Hayır'),
                        ],
                      ),
                      if (isAuto) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Otomatik Pilot Takvimi:',
                          style: GoogleFonts.outfit(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color:
                                    const Color(0xFF10B981).withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: Color(0xFF10B981), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _autoFreq == 'Daily'
                                          ? 'Her Gün'
                                          : _autoFreq == 'Weekly'
                                              ? 'Her Hafta (${_getDayName(_autoDay ?? 1, AppLocalizations.of(context)!)})'
                                              : 'Her Ay (${_autoDay}. Gün)',
                                      style: GoogleFonts.outfit(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Saat: ${_autoTime.format(context)} aktif olacak.',
                                      style: GoogleFonts.outfit(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'Kapsanan Konular:',
                        style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: outline.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      const Color(0xFF10B981).withOpacity(0.2)),
                            ),
                            child: Text(
                              item.toString(),
                              style: GoogleFonts.outfit(
                                  color: const Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Stage 3: Confirm and queue background generation
                    if (isAuto) {
                      await _saveAutoPilotConfig(showSnackbar: false);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Otomatik Sınav Planlandı! ✨'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        // Clear the prompt input and attachment
                        _autoPromptController.clear();
                        setState(() => _autoAttachedFile = null);
                      }
                    } else {
                      await ref.read(examsProvider.notifier).proposeExam(
                          plan, finalPrompt,
                          fileBase64: fileBase64,
                          fileMime: fileMime,
                          isAuto: isAuto);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                                'Sınavınız hazırlanıyor, bitince bildirim alacaksınız. ✨'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        // Refresh exams list to see the "QUEUED" exam
                        ref.read(examsProvider.notifier).fetchExams();
                        // Clear the prompt input and attachment
                        _promptController.clear();
                        setState(() => _attachedFile = null);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Oluştur',
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Vazgeç',
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTag(IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF10B981)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _generateExam({bool isAuto = false}) async {
    String finalPrompt = '';
    if (isAuto) {
      if (_autoIsPromptTab) {
        if (_autoPromptController.text.trim().isEmpty) return;
        finalPrompt = _autoPromptController.text.trim();
      } else {
        final l10n = AppLocalizations.of(context)!;
        bool isOther = _autoSubtopic == l10n.dashboardFilterSubtopicOther;
        String subtopicStr = (_autoSubtopic != 'All' && !isOther)
            ? 'Sub-topic: $_autoSubtopic. '
            : '';
        String titlesStr = _autoSubtopics.isNotEmpty
            ? 'Extra titles to cover: ${_autoSubtopics.join(", ")}. '
            : '';
        String typeStr = _autoType == 'Mixed'
            ? 'a mixed exam (include Multiple Choice, True/False, and Open Ended questions)'
            : 'a $_autoType exam';
        finalPrompt =
            'Create $typeStr for $_autoLevel about $_autoTopic. ${subtopicStr}${titlesStr}Question count: $_autoCount.';
      }
    } else {
      if (_isPromptTab) {
        if (_promptController.text.trim().isEmpty) return;
        finalPrompt = _promptController.text.trim();
      } else {
        final l10n = AppLocalizations.of(context)!;
        bool isOther = _selectedSubtopic == l10n.dashboardFilterSubtopicOther;
        String subtopicStr = (_selectedSubtopic != 'All' && !isOther)
            ? 'Sub-topic: $_selectedSubtopic. '
            : '';
        String titlesStr = _subtopics.isNotEmpty
            ? 'Extra titles to cover: ${_subtopics.join(", ")}. '
            : '';
        String typeStr = _selectedType == 'Mixed'
            ? 'a mixed exam (include Multiple Choice, True/False, and Open Ended questions)'
            : 'a $_selectedType exam';
        finalPrompt =
            'Create $typeStr for $_selectedLevel about $_selectedTopic. ${subtopicStr}${titlesStr}Question count: $_selectedCount.';
      }
    }

    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.getDraftPlan(finalPrompt,
          attachment: isAuto ? _autoAttachedFile : _attachedFile);
      final plan = result['suggested'];
      final fileBase64 = result['fileBase64'] as String?;
      final fileMime = result['fileMime'] as String?;
      // Store for later use in confirm
      _draftFileBase64 = fileBase64;
      _draftFileMime = fileMime;
      setState(() => _loading = false);

      if (plan['isValid'] == false) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text('Sınav Planlanamadı',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: Text(
                plan['error'] ??
                    'Girdiğiniz prompt sınav oluşturmak için yeterli değil.',
                style: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tamam',
                      style:
                          GoogleFonts.outfit(color: const Color(0xFF10B981))),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (mounted) {
        _showPlanDialog(plan, finalPrompt,
            fileBase64: _draftFileBase64,
            fileMime: _draftFileMime,
            isAuto: isAuto);
      }
    } on DioException catch (e) {
      setState(() => _loading = false);
      if (e.response?.statusCode == 403) {
        final errorMsg = e.response?.data?['error'] ?? 'Limit uyarısı';
        _showUpgradeDialog(errorMsg);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: ${e.response?.data?['error'] ?? e.message}')),
          );
        }
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Beklenmedik bir hata oluştu: $e')),
        );
      }
    }
  }

  void _showUpgradeDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 12),
            Text('Limit Doldu',
                style: GoogleFonts.outfit(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Daha Sonra',
                style: GoogleFonts.outfit(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Şimdi Yükselt',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final exams = ref.watch(examsProvider);
    final autoExams = exams.where((e) => e.isAuto).toList();
    final manualExams = exams.where((e) => !e.isAuto).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF021A12) : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background Orbs
          const Positioned(
            top: -50,
            left: -100,
            child: GlowingOrb(size: 300, color: Color(0xFF065F46)),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.1,
            right: -100,
            child: const GlowingOrb(size: 400, color: Color(0xFF047857)),
          ),
          const Positioned(
            top: 400,
            left: 100,
            child:
                GlowingOrb(size: 200, color: Color(0xFF10B981), opacity: 0.2),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 32),
                  _buildCreateExamCard(l10n),
                  const SizedBox(height: 32),
                  _buildAutoPilotCard(l10n),
                  const SizedBox(height: 32),
                  _buildExamsListCard(l10n.dashboardAutoExamsTitle, autoExams,
                      l10n, Icons.auto_awesome),
                  const SizedBox(height: 32),
                  _buildExamsListCard(l10n.dashboardArchiveTitle, manualExams,
                      l10n, Icons.folder_copy),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    final user = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashboardGreeting,
                    style: GoogleFonts.outfit(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 13)),
                Text(user?.name ?? 'AI Master',
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        _buildIconButton(
            Icons.settings_outlined, () => context.push('/settings')),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06)),
      ),
      child: IconButton(
          onPressed: onTap,
          icon: Icon(icon,
              color: isDark ? Colors.white : Colors.black87, size: 22)),
    );
  }

  Widget _buildCreateExamCard(AppLocalizations l10n) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.asset(
              'assets/images/header_up.png',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Color(0xFF10B981), size: 22),
                    const SizedBox(width: 10),
                    Text(l10n.dashboardCreateTitle,
                        style: GoogleFonts.outfit(
                            color: _isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTabSwitcher(l10n),
                const SizedBox(height: 20),
                if (_isPromptTab) ...[
                  _buildPromptField(l10n),
                  const SizedBox(height: 16),
                  _buildAttachmentArea(l10n),
                ] else
                  _buildFilterGrid(l10n),
                const SizedBox(height: 24),
                _buildGenerateButton(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
              child: _TabButton(
            label: l10n.dashboardTabPrompt,
            icon: Icons.auto_awesome,
            isActive: _isPromptTab,
            onTap: () => setState(() => _isPromptTab = true),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: _TabButton(
            label: l10n.dashboardTabFilter,
            icon: Icons.tune,
            isActive: !_isPromptTab,
            onTap: () => setState(() => _isPromptTab = false),
          )),
        ],
      ),
    );
  }

  Widget _buildPromptField(AppLocalizations l10n) {
    return TextField(
      controller: _promptController,
      maxLines: 4,
      style: GoogleFonts.outfit(color: _isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: l10n.dashboardPromptHint,
        hintStyle: GoogleFonts.outfit(
            color: _isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
            fontSize: 14),
        filled: true,
        fillColor: _isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.photo_library, color: Colors.blueAccent),
                ),
                title: Text(
                  l10n.attachmentSourceGallery,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFileFromPlatform(FileType.image);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file,
                      color: Colors.orangeAccent),
                ),
                title: Text(
                  l10n.attachmentSourceFiles,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFileFromPlatform(FileType.custom, allowedExtensions: [
                    'pdf',
                    'jpg',
                    'jpeg',
                    'png',
                    'heic',
                    'webp'
                  ]);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFileFromPlatform(FileType type,
      {List<String>? allowedExtensions}) async {
    try {
      debugPrint('[FilePicker] Opening picker...');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya seçici açılıyor...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final ext = path.split('.').last.toLowerCase();
        final allowed = ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'];

        if (!allowed.contains(ext)) {
          debugPrint('[FilePicker] Invalid file type: $ext');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Sadece PDF ve görsel yüklenebilir (Videolar kabul edilmez)'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        debugPrint('[FilePicker] File picked: $path');
        setState(() => _attachedFile = File(path));
      } else {
        debugPrint('[FilePicker] No file picked or picker cancelled.');
      }
    } catch (e) {
      debugPrint('[FilePicker] Error: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildAttachmentArea(AppLocalizations l10n) {
    if (_attachedFile != null) {
      final fileName = _attachedFile!.path.split('/').last;
      final fileSize = _attachedFile!.lengthSync();
      final isPdf = fileName.toLowerCase().endsWith('.pdf');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPdf
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: isPdf ? Colors.redAccent : Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: GoogleFonts.outfit(
                      color: _isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatFileSize(fileSize),
                    style: GoogleFonts.outfit(
                      color: _isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _attachedFile = null),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.close, size: 16, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state — dashed border upload zone
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
            borderRadius: 16,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: _isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF veya Görsel Ekle',
                  style: GoogleFonts.outfit(
                    color: _isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, JPG, PNG, HEIC, WEBP (maks. 10MB)',
                  style: GoogleFonts.outfit(
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterGrid(AppLocalizations l10n) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _FilterBox(
                icon: Icons.school_outlined,
                label: l10n.dashboardFilterLevel,
                value: _getLevelTitle(_selectedLevel, l10n),
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterLevel,
                    [
                      'Elementary',
                      'Middle School',
                      'High School',
                      'University',
                      'College',
                      'Professional'
                    ],
                    (v) => setState(() => _selectedLevel = v),
                    valueLocalizer: (level) => _getLevelTitle(level, l10n))),
            _FilterBox(
                icon: Icons.book_outlined,
                label: l10n.dashboardFilterTopic,
                value: _selectedTopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterTopic,
                    _topicData.keys.toList(),
                    (v) => setState(() {
                          _selectedTopic = v;
                          _selectedSubtopic = 'All'; // Reset subtopic
                        }))),
            _FilterBox(
                icon: Icons.subject_outlined,
                label: l10n.dashboardFilterSubtopic,
                value: _selectedSubtopic == 'All'
                    ? l10n.dashboardFilterAll
                    : _selectedSubtopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterSubtopicSelect,
                    [
                      'All',
                      ...(_topicData[_selectedTopic] ?? []),
                      l10n.dashboardFilterSubtopicOther
                    ],
                    (v) => setState(() {
                          _selectedSubtopic = v;
                          if (v == l10n.dashboardFilterSubtopicOther) {
                            _subtopicFocusNode.requestFocus();
                          }
                        }),
                    valueLocalizer: (val) =>
                        val == 'All' ? l10n.dashboardFilterAll : val)),
            _FilterBox(
                icon: Icons.format_list_numbered,
                label: l10n.dashboardFilterCount,
                value: '$_selectedCount Q',
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterCount,
                    ['5', '10', '15'],
                    (v) => setState(() => _selectedCount = int.parse(v)))),
            _FilterBox(
                icon: Icons.fact_check_outlined,
                label: l10n.dashboardFilterType,
                value: _getTypeTitle(_selectedType, l10n),
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterType,
                    ['Multiple Choice', 'Open Ended', 'True/False', 'Mixed'],
                    (v) => setState(() => _selectedType = v),
                    valueLocalizer: (type) => _getTypeTitle(type, l10n))),
          ],
        ),
        const SizedBox(height: 12),
        _buildSubtopicInput(l10n),
        if (_subtopics.isNotEmpty) _buildSubtopicChips(),
      ],
    );
  }

  Widget _buildSubtopicInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _subtopicController,
              focusNode: _subtopicFocusNode,
              style: GoogleFonts.outfit(
                  color: _isDark ? Colors.white : Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                hintText: l10n.dashboardFilterTitleHint,
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
              onSubmitted: (v) => _addSubtopic(v),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _addSubtopic(_subtopicController.text),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _addSubtopic(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _subtopics.add(value.trim());
        _subtopicController.clear();
      });
    }
  }

  Widget _buildSubtopicChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _subtopics
            .map((s) => Chip(
                  label: Text(s,
                      style: GoogleFonts.outfit(
                          color: _isDark ? Colors.white : Colors.black87,
                          fontSize: 12)),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  onDeleted: () => setState(() => _subtopics.remove(s)),
                  deleteIcon:
                      const Icon(Icons.close, size: 14, color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildGenerateButton(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)]),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 30)
        ],
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : () => _generateExam(isAuto: false),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(l10n.dashboardGenerateBtn,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
      ),
    );
  }

  Widget _buildAutoPilotCard(AppLocalizations l10n) {
    final user = ref.watch(authProvider).user;
    final bool isPro = user?.subscriptionTier == 'PRO';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month,
                  color: Color(0xFF10B981), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(l10n.dashboardAutoTitle,
                      style: GoogleFonts.outfit(
                          color: _isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              if (_autoFreq != 'Passive') ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(l10n.dashboardAutoActive,
                          style: GoogleFonts.outfit(
                              color: const Color(0xFF10B981),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(l10n.dashboardAutoDesc,
              style: GoogleFonts.outfit(
                  color: const Color(0xFF94A3B8), fontSize: 13)),
          const SizedBox(height: 24),

          // Frequency Selection
          Column(
            children: [
              _ScheduleCard(
                  label: l10n.dashboardFreqDaily,
                  time: _autoFreq == 'Daily'
                      ? _autoTime.format(context)
                      : l10n.dashboardFreqPassive,
                  isActive: _autoFreq == 'Daily',
                  isPro: isPro,
                  onTap: () => setState(() => _autoFreq = 'Daily')),
              const SizedBox(height: 12),
              _ScheduleCard(
                  label: l10n.dashboardFreqWeekly,
                  time: _autoFreq == 'Weekly'
                      ? '${_getDayName(_autoDay ?? 1, l10n)}, ${_autoTime.format(context)}'
                      : l10n.dashboardFreqPassive,
                  isActive: _autoFreq == 'Weekly',
                  isPro: isPro,
                  onTap: () => setState(() => _autoFreq = 'Weekly')),
              const SizedBox(height: 12),
              _ScheduleCard(
                  label: l10n.dashboardFreqMonthly,
                  time: _autoFreq == 'Monthly'
                      ? '${l10n.dashboardAutoDayMonthly(_autoDay ?? 1)}, ${_autoTime.format(context)}'
                      : l10n.dashboardFreqPassive,
                  isActive: _autoFreq == 'Monthly',
                  isPro: isPro,
                  onTap: () => setState(() => _autoFreq = 'Monthly')),
            ],
          ),

          if (_autoFreq != 'Passive') ...[
            const SizedBox(height: 24),
            _buildAutoPilotSchedulingInputs(l10n),
            const SizedBox(height: 24),
            const Divider(color: Colors.white10),
            const SizedBox(height: 24),

            // Integrated Exam Template Tabs
            Text(l10n.dashboardFilterExamTemplate,
                style: GoogleFonts.outfit(
                    color: _isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAutoTabSwitcher(l10n),
            const SizedBox(height: 16),
            if (_autoIsPromptTab)
              _buildAutoPromptField(l10n)
            else
              _buildAutoFilterGrid(l10n),

            const SizedBox(height: 24),
            _buildAutoSaveButton(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoPilotSchedulingInputs(AppLocalizations l10n) {
    return Row(
      children: [
        if (_autoFreq == 'Weekly')
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_today,
              label: _getDayName(_autoDay ?? 1, l10n),
              onTap: _selectAutoDay,
            ),
          ),
        if (_autoFreq == 'Monthly')
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_today,
              label: l10n.dashboardAutoDayMonthly(_autoDay ?? 1),
              onTap: _selectAutoDay,
            ),
          ),
        if (_autoFreq != 'Daily') const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.access_time,
            label: _autoTime.format(context),
            onTap: _selectAutoTime,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.outfit(
                    color: _isDark ? Colors.white : Colors.black87,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day, AppLocalizations l10n) {
    final days = [
      l10n.dayMon,
      l10n.dayTue,
      l10n.dayWed,
      l10n.dayThu,
      l10n.dayFri,
      l10n.daySat,
      l10n.daySun
    ];
    return days[(day - 1) % 7];
  }

  void _selectAutoTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _autoTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
              primary: Color(0xFF10B981), onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _autoTime = picked);
  }

  void _selectAutoDay() {
    if (_autoFreq == 'Weekly') {
      _showDayPicker();
    } else if (_autoFreq == 'Monthly') {
      _showMonthDayPicker();
    }
  }

  void _showDayPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF022C22),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final days = [
          'Pazartesi',
          'Salı',
          'Çarşamba',
          'Perşembe',
          'Cuma',
          'Cumartesi',
          'Pazar'
        ];
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Gün Seçin",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = (_autoDay ?? 1) == (index + 1);
                  return GestureDetector(
                    onTap: () {
                      setState(() => _autoDay = index + 1);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(days[index],
                          style: GoogleFonts.outfit(
                              color: isSelected ? Colors.black : Colors.white)),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthDayPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF022C22),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ayın Günü Seçin",
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 29,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = (_autoDay ?? 1) == day;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _autoDay = day);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("$day",
                            style: GoogleFonts.outfit(
                                color: isSelected ? Colors.black : Colors.white,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterMenu(
      String label, List<String> options, Function(String) onSelect,
      {String Function(String)? valueLocalizer}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              children: [
                Center(
                  child: Text(label,
                      style: GoogleFonts.outfit(
                          color: _isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  right: 0,
                  top: -8,
                  child: IconButton(
                    icon: Icon(Icons.close,
                        color: _isDark ? Colors.white60 : Colors.black45),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(color: Colors.white.withValues(alpha: 0.05)),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                        valueLocalizer != null
                            ? valueLocalizer(options[index])
                            : options[index],
                        style: GoogleFonts.outfit(
                            color: _isDark ? Colors.white : Colors.black87,
                            fontSize: 15)),
                    onTap: () {
                      onSelect(options[index]);
                      Navigator.pop(context);
                    },
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF10B981), size: 18),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoTabSwitcher(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _isDark
            ? Colors.black.withValues(alpha: 0.3)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: l10n.dashboardTabPrompt,
              icon: Icons.auto_awesome,
              isActive: _autoIsPromptTab,
              onTap: () => setState(() => _autoIsPromptTab = true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TabButton(
              label: l10n.dashboardTabFilter,
              icon: Icons.tune,
              isActive: !_autoIsPromptTab,
              onTap: () => setState(() => _autoIsPromptTab = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoPromptField(AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _autoPromptController,
          maxLines: 3,
          style: GoogleFonts.outfit(
              color: _isDark ? Colors.white : Colors.black87, fontSize: 13),
          decoration: InputDecoration(
            hintText: "Otomasyon için sınav açıklaması...",
            hintStyle: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8), fontSize: 12),
            filled: true,
            fillColor: _isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                  color: _isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : const Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF10B981), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildAutoAttachmentArea(l10n),
      ],
    );
  }

  Widget _buildAutoFilterGrid(AppLocalizations l10n) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            _FilterBox(
                icon: Icons.school_outlined,
                label: l10n.dashboardFilterLevel,
                value: _getLevelTitle(_autoLevel, l10n),
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterLevel,
                    [
                      'Elementary',
                      'Middle School',
                      'High School',
                      'University',
                      'College',
                      'Professional'
                    ],
                    (v) => setState(() => _autoLevel = v),
                    valueLocalizer: (level) => _getLevelTitle(level, l10n))),
            _FilterBox(
                icon: Icons.book_outlined,
                label: l10n.dashboardFilterTopic,
                value: _autoTopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterTopic,
                    _topicData.keys.toList(),
                    (v) => setState(() {
                          _autoTopic = v;
                          _autoSubtopic = 'All'; // Reset subtopic
                        }))),
            _FilterBox(
                icon: Icons.subject_outlined,
                label: l10n.dashboardFilterSubtopic,
                value: _autoSubtopic == 'All'
                    ? l10n.dashboardFilterAll
                    : _autoSubtopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterSubtopicSelect,
                    [
                      'All',
                      ...(_topicData[_autoTopic] ?? []),
                      l10n.dashboardFilterSubtopicOther
                    ],
                    (v) => setState(() {
                          _autoSubtopic = v;
                          if (v == l10n.dashboardFilterSubtopicOther) {
                            _autoSubtopicFocusNode.requestFocus();
                          }
                        }),
                    valueLocalizer: (val) =>
                        val == 'All' ? l10n.dashboardFilterAll : val)),
            _FilterBox(
                icon: Icons.format_list_numbered,
                label: l10n.dashboardFilterCount,
                value: '$_autoCount Q',
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterCount,
                    ['5', '10', '15', '20', '25', '30'],
                    (v) => setState(() => _autoCount = int.parse(v)))),
            _FilterBox(
                icon: Icons.fact_check_outlined,
                label: l10n.dashboardFilterType,
                value: _getTypeTitle(_autoType, l10n),
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterType,
                    ['Multiple Choice', 'Open Ended', 'True/False', 'Mixed'],
                    (v) => setState(() => _autoType = v),
                    valueLocalizer: (type) => _getTypeTitle(type, l10n))),
          ],
        ),
        const SizedBox(height: 12),
        _buildAutoSubtopicInput(l10n),
        if (_autoSubtopics.isNotEmpty) _buildAutoSubtopicChips(),
      ],
    );
  }

  Future<void> _pickAutoFile() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.photo_library, color: Colors.blueAccent),
                ),
                title: Text(
                  l10n.attachmentSourceGallery,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAutoFileFromPlatform(FileType.image);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file,
                      color: Colors.orangeAccent),
                ),
                title: Text(
                  l10n.attachmentSourceFiles,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickAutoFileFromPlatform(FileType.custom,
                      allowedExtensions: [
                        'pdf',
                        'jpg',
                        'jpeg',
                        'png',
                        'heic',
                        'webp'
                      ]);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAutoFileFromPlatform(FileType type,
      {List<String>? allowedExtensions}) async {
    try {
      debugPrint('[FilePicker-Auto] Opening picker...');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dosya seçici açılıyor...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final ext = path.split('.').last.toLowerCase();
        final allowed = ['pdf', 'jpg', 'jpeg', 'png', 'heic', 'webp'];

        if (!allowed.contains(ext)) {
          debugPrint('[FilePicker-Auto] Invalid file type: $ext');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Sadece PDF ve görsel yüklenebilir (Videolar kabul edilmez)'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }

        debugPrint('[FilePicker-Auto] File picked: $path');
        setState(() => _autoAttachedFile = File(path));
      } else {
        debugPrint('[FilePicker-Auto] No file picked or picker cancelled.');
      }
    } catch (e) {
      debugPrint('[FilePicker-Auto] Error: $e');
    }
  }

  Widget _buildAutoAttachmentArea(AppLocalizations l10n) {
    if (_autoAttachedFile != null) {
      final fileName = _autoAttachedFile!.path.split('/').last;
      final fileSize = _autoAttachedFile!.lengthSync();
      final isPdf = fileName.toLowerCase().endsWith('.pdf');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPdf
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image,
                color: isPdf ? Colors.redAccent : Colors.blueAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: GoogleFonts.outfit(
                      color: _isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatFileSize(fileSize),
                    style: GoogleFonts.outfit(
                      color: _isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _autoAttachedFile = null),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.close, size: 16, color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickAutoFile,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isDark
                ? Colors.white.withValues(alpha: 0.15)
                : const Color(0xFFCBD5E1),
            borderRadius: 16,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  color: _isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF veya Görsel Ekle',
                  style: GoogleFonts.outfit(
                    color: _isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, JPG, PNG, HEIC, WEBP (maks. 10MB)',
                  style: GoogleFonts.outfit(
                    color: _isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : () => _generateExam(isAuto: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFF10B981),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF10B981)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              )
            : Text(l10n.dashboardAutoSave,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildExamsListCard(
      String title, List<Exam> exams, AppLocalizations l10n, IconData icon) {
    final bool isAutoList = title == l10n.dashboardAutoExamsTitle;

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF10B981), size: 22),
                  const SizedBox(width: 10),
                  Text(title,
                      style: GoogleFonts.outfit(
                          color: _isDark ? Colors.white : Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              if (!isAutoList)
                InkWell(
                  onTap: () => context.push('/my-exams/list'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(l10n.dashboardViewAll,
                        style: GoogleFonts.outfit(
                            color: const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (isAutoList)
            if (_autoPilotConfigs.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Aktif bir otomatik sınav talimatınız yok...',
                          style: TextStyle(color: Colors.white38))))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _autoPilotConfigs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) => _AutoPilotInstructionCard(
                  config: _autoPilotConfigs[index],
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AutoPilotDetailScreen(
                          config: _autoPilotConfigs[index],
                        ),
                      ),
                    );
                    if (result == true) _fetchAutoPilotConfigs();
                  },
                ),
              )
          else if (exams.isEmpty)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Henüz normal sınav yok...',
                        style: const TextStyle(color: Colors.white38))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exams.length > 3 ? 3 : exams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _ArchiveListItem(
                exam: exams[index],
                onShowDuration: _showDurationPicker,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoSubtopicInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _autoSubtopicController,
              focusNode: _autoSubtopicFocusNode,
              style: GoogleFonts.outfit(
                  color: _isDark ? Colors.white : Colors.black87, fontSize: 13),
              decoration: InputDecoration(
                hintText: l10n.dashboardFilterTitleHint,
                hintStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
              onSubmitted: (v) => _addAutoSubtopic(v),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _addAutoSubtopic(_autoSubtopicController.text),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add, size: 24, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _addAutoSubtopic(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _autoSubtopics.add(value.trim());
        _autoSubtopicController.clear();
      });
    }
  }

  Widget _buildAutoSubtopicChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _autoSubtopics
            .map((s) => Chip(
                  label: Text(s,
                      style: GoogleFonts.outfit(
                          color: _isDark ? Colors.white : Colors.black87,
                          fontSize: 12)),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  onDeleted: () => setState(() => _autoSubtopics.remove(s)),
                  deleteIcon:
                      const Icon(Icons.close, size: 14, color: Colors.white),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ))
            .toList(),
      ),
    );
  }

  void _showDurationPicker(BuildContext context, Exam exam) {
    int selectedDuration = 10;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sınav Süresini Ayarla',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sınavı kaç dakikada tamamlamak istersin?',
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DurationBtn(
                    icon: Icons.remove,
                    onTap: selectedDuration > 5
                        ? () => setModalState(() => selectedDuration -= 5)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '$selectedDuration dk',
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _DurationBtn(
                    icon: Icons.add,
                    onTap: selectedDuration < 120
                        ? () => setModalState(() => selectedDuration += 5)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                        '/my-exams/${exam.id}?duration=$selectedDuration');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sınava Başla',
                    style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoPilotInstructionCard extends StatelessWidget {
  final AutoPilotConfig config;
  final VoidCallback onTap;

  const _AutoPilotInstructionCard({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Color(0xFF10B981), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title ?? config.topic ?? 'Otomatik Sınav',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${config.frequency.toUpperCase()} - ${config.time}',
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white60 : Colors.black54,
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
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF10B981) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isActive ? const Color(0xFF022C22) : inactiveColor),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: GoogleFonts.outfit(
                        color:
                            isActive ? const Color(0xFF022C22) : inactiveColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _FilterBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black38),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String label;
  final String time;
  final bool isActive;
  final VoidCallback onTap;
  final bool isPro;

  const _ScheduleCard({
    required this.label,
    required this.time,
    this.isActive = false,
    required this.onTap,
    this.isPro = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isPro ? onTap : () => context.push('/subscription'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.white10 : const Color(0xFFCBD5E1))),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_motion,
                  color: isActive
                      ? const Color(0xFF10B981)
                      : (isDark ? Colors.white24 : Colors.black26),
                  size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  Text(time,
                      style: GoogleFonts.outfit(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B)),
                          fontSize: 13)),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle,
                  color: Color(0xFF10B981), size: 24),
          ],
        ),
      ),
    );
  }
}

class _ArchiveListItem extends StatelessWidget {
  final Exam exam;
  final Function(BuildContext, Exam) onShowDuration;
  const _ArchiveListItem({required this.exam, required this.onShowDuration});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.06)),
      ),
      child: InkWell(
        onTap: exam.status == ExamStatus.ready
            ? () => onShowDuration(context, exam)
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.horizontal(left: Radius.circular(20)),
                image: DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=200&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(exam.title,
                              style: GoogleFonts.outfit(
                                  color: exam.status == ExamStatus.ready
                                      ? (isDark ? Colors.white : Colors.black87)
                                      : (isDark
                                          ? Colors.white54
                                          : Colors.black45),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        StatusChip(status: exam.status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('${exam.questionCount} Soru',
                            style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontSize: 12)),
                        if (exam.status == ExamStatus.ready &&
                            exam.lastScore != null) ...[
                          const SizedBox(width: 8),
                          Text('Başarı Oranın: %${exam.lastScore!.toInt()}',
                              style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _DurationBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1))
                : (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05)),
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white24 : Colors.black26),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));

    const dashWidth = 6.0;
    const dashGap = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
