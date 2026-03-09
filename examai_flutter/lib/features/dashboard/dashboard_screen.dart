import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/providers.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _promptController = TextEditingController();
  final _subtopicController = TextEditingController();
  bool _loading = false;
  bool _isPromptTab = true;

  // Manual Create Filter states
  String _selectedLevel = 'High School';
  String _selectedTopic = 'General';
  int _selectedCount = 10;
  String _selectedType = 'Multiple Choice';
  final List<String> _subtopics = [];

  // Auto-Pilot states
  String _autoFreq = 'Daily'; // Daily, Weekly, Monthly, Passive
  int? _autoDay; // 1-7 for Weekly, 1-31 for Monthly
  TimeOfDay _autoTime = const TimeOfDay(hour: 20, minute: 0);
  bool _autoIsPromptTab = true;
  final _autoPromptController = TextEditingController();
  final _autoSubtopicController = TextEditingController();
  String _autoLevel = 'High School';
  String _autoTopic = 'Math';
  int _autoCount = 10;
  String _autoType = 'Multiple Choice';
  final List<String> _autoSubtopics = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(examsProvider.notifier).fetchExams());
  }

  @override
  void dispose() {
    _promptController.dispose();
    _subtopicController.dispose();
    _autoPromptController.dispose();
    _autoSubtopicController.dispose();
    super.dispose();
  }

  void _showPlanDialog(Map<String, dynamic> plan, String finalPrompt) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['title'] ?? 'Exam Plan',
              style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildPlanInfoRow(Icons.question_answer_outlined,
                '${plan['questionCount']} Questions'),
            _buildPlanInfoRow(
                Icons.timer_outlined, '${plan['durationMin']} Minutes'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(examsProvider.notifier)
                      .proposeExam(finalPrompt);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exam is being prepared!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm & Generate',
                    style: GoogleFonts.outfit(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: GoogleFonts.outfit(color: Colors.white60)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfoRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 24),
          const SizedBox(width: 16),
          Text(label,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _generateExam() async {
    String finalPrompt = '';
    if (_isPromptTab) {
      if (_promptController.text.trim().isEmpty) return;
      finalPrompt = _promptController.text.trim();
    } else {
      finalPrompt =
          'Create a $_selectedType exam for $_selectedLevel about $_selectedTopic. Subtopics: ${_subtopics.join(", ")}. Question count: $_selectedCount.';
    }

    setState(() => _loading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final plan = await api.getDraftPlan(finalPrompt);
      if (mounted) {
        _showPlanDialog(plan, finalPrompt);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF021A12),
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
                  _buildMyArchiveCard(l10n),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981), width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=100&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.dashboardGreeting,
                    style: GoogleFonts.outfit(
                        color: const Color(0xFF94A3B8), fontSize: 13)),
                Text(user?.name ?? 'AI Master',
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        _buildIconButton(
            Icons.settings_outlined, () => context.push('/my-exams/settings')),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IconButton(
          onPressed: onTap, icon: Icon(icon, color: Colors.white, size: 22)),
    );
  }

  Widget _buildCreateExamCard(AppLocalizations l10n) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.network(
              'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=600&q=80',
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
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTabSwitcher(l10n),
                const SizedBox(height: 20),
                if (_isPromptTab)
                  _buildPromptField(l10n)
                else
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
        color: Colors.black.withValues(alpha: 0.3),
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
      style: GoogleFonts.outfit(color: Colors.white),
      decoration: InputDecoration(
        hintText: l10n.dashboardPromptHint,
        hintStyle:
            GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 14),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
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
                value: _selectedLevel,
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
                    (v) => setState(() => _selectedLevel = v))),
            _FilterBox(
                icon: Icons.book_outlined,
                label: l10n.dashboardFilterTopic,
                value: _selectedTopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterTopic,
                    [
                      'Math',
                      'Science',
                      'History',
                      'Literature',
                      'General',
                      'Technology',
                      'Art'
                    ],
                    (v) => setState(() => _selectedTopic = v))),
            _FilterBox(
                icon: Icons.format_list_numbered,
                label: l10n.dashboardFilterCount,
                value: '$_selectedCount Q',
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterCount,
                    ['5', '10', '15', '20', '25', '30'],
                    (v) => setState(() => _selectedCount = int.parse(v)))),
            _FilterBox(
                icon: Icons.fact_check_outlined,
                label: l10n.dashboardFilterType,
                value: _selectedType,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterType,
                    [
                      'Multiple Choice',
                      'Open Ended',
                      'True/False',
                      'Fill in the Blanks'
                    ],
                    (v) => setState(() => _selectedType = v))),
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
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: l10n.dashboardFilterSubtopicHint,
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
                          color: Colors.white, fontSize: 12)),
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
        onPressed: _loading ? null : _generateExam,
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
                          color: Colors.white,
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
                      : 'Passive',
                  isActive: _autoFreq == 'Daily',
                  onTap: () => setState(() => _autoFreq = 'Daily')),
              const SizedBox(height: 12),
              _ScheduleCard(
                  label: l10n.dashboardFreqWeekly,
                  time: _autoFreq == 'Weekly'
                      ? '${_getDayName(_autoDay ?? 1)}, ${_autoTime.format(context)}'
                      : 'Passive',
                  isActive: _autoFreq == 'Weekly',
                  onTap: () => setState(() => _autoFreq = 'Weekly')),
              const SizedBox(height: 12),
              _ScheduleCard(
                  label: l10n.dashboardFreqMonthly,
                  time: _autoFreq == 'Monthly'
                      ? '${_autoDay ?? 1}. G., ${_autoTime.format(context)}'
                      : 'Passive',
                  isActive: _autoFreq == 'Monthly',
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
            Text("Sınav Şablonu",
                style: GoogleFonts.outfit(
                    color: Colors.white,
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
              label: _getDayName(_autoDay ?? 1),
              onTap: _selectAutoDay,
            ),
          ),
        if (_autoFreq == 'Monthly')
          Expanded(
            child: _buildActionButton(
              icon: Icons.calendar_today,
              label: '${_autoDay ?? 1}. Gün',
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
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
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
                  itemCount: 31,
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
      String label, List<String> options, Function(String) onSelect) {
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
            const SizedBox(height: 20),
            Text(label,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
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
                    title: Text(options[index],
                        style: GoogleFonts.outfit(
                            color: Colors.white, fontSize: 15)),
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
        color: Colors.black.withValues(alpha: 0.3),
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
    return TextField(
      controller: _autoPromptController,
      maxLines: 3,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: "Otomasyon için sınav açıklaması...",
        hintStyle:
            GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 12),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.3),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildAutoFilterGrid(AppLocalizations l10n) {
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            _FilterBox(
                icon: Icons.school_outlined,
                label: l10n.dashboardFilterLevel,
                value: _autoLevel,
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
                    (v) => setState(() => _autoLevel = v))),
            _FilterBox(
                icon: Icons.book_outlined,
                label: l10n.dashboardFilterTopic,
                value: _autoTopic,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterTopic,
                    [
                      'Math',
                      'Science',
                      'History',
                      'Literature',
                      'General',
                      'Technology',
                      'Art'
                    ],
                    (v) => setState(() => _autoTopic = v))),
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
                value: _autoType,
                onTap: () => _showFilterMenu(
                    l10n.dashboardFilterType,
                    [
                      'Multiple Choice',
                      'Open Ended',
                      'True/False',
                      'Fill in the Blanks'
                    ],
                    (v) => setState(() => _autoType = v))),
          ],
        ),
        const SizedBox(height: 12),
        _buildAutoSubtopicInput(l10n),
        if (_autoSubtopics.isNotEmpty) _buildAutoSubtopicChips(),
      ],
    );
  }

  Widget _buildAutoSaveButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dashboardAutoSave)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
          foregroundColor: const Color(0xFF10B981),
          elevation: 0,
          side: const BorderSide(color: Color(0xFF10B981)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(l10n.dashboardAutoSave,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMyArchiveCard(AppLocalizations l10n) {
    final exams = ref.watch(examsProvider);
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_copy,
                      color: Color(0xFF10B981), size: 22),
                  const SizedBox(width: 10),
                  Text(l10n.dashboardArchiveTitle,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text(l10n.dashboardViewAll,
                  style: GoogleFonts.outfit(
                      color: const Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          if (exams.isEmpty)
            const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Empty Arhive...',
                        style: TextStyle(color: Colors.white38))))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exams.length > 3 ? 3 : exams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _ArchiveListItem(exam: exams[index]),
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
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: l10n.dashboardFilterSubtopicHint,
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
                          color: Colors.white, fontSize: 12)),
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
                color: isActive
                    ? const Color(0xFF022C22)
                    : const Color(0xFF94A3B8)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label,
                    style: GoogleFonts.outfit(
                        color: isActive
                            ? const Color(0xFF022C22)
                            : const Color(0xFF94A3B8),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                          color: const Color(0xFF94A3B8), fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.4)),
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

  const _ScheduleCard(
      {required this.label,
      required this.time,
      this.isActive = false,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF10B981).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? const Color(0xFF10B981) : Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF10B981).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_motion,
                  color: isActive ? const Color(0xFF10B981) : Colors.white24,
                  size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  Text(time,
                      style: GoogleFonts.outfit(
                          color: isActive
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
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
  const _ArchiveListItem({required this.exam});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
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
                  Text(exam.title,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                      maxLines: 1),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('${exam.questionCount} Questions',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12)),
                      if (exam.lastScore != null) ...[
                        const SizedBox(width: 8),
                        Text('%${exam.lastScore} Puan',
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
    );
  }
}
