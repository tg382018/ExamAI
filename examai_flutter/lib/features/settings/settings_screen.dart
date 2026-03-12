import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final remindersEnabled = ref.watch(remindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayarlar',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildSectionHeader(context, 'Görünüm'),
          _buildSettingTile(
            context,
            icon:
                isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            title: 'Koyu Tema',
            subtitle: isDarkMode ? 'Karanlık mod aktif' : 'Aydınlık mod aktif',
            trailing: Switch.adaptive(
              value: isDarkMode,
              activeColor: const Color(0xFF10B981),
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Hesap Güvenliği'),
          _buildSettingTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Şifre Değiştir',
            subtitle: 'Hesap güvenliğini artırın',
            onTap: () => _showChangePasswordDialog(context),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Bildirimler'),
          _buildSettingTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Sınav Hatırlatıcıları',
            subtitle: 'Günlük sınav bildirimleri',
            trailing: Switch.adaptive(
              value: remindersEnabled,
              activeColor: const Color(0xFF10B981),
              onChanged: (_) =>
                  ref.read(remindersProvider.notifier).toggleReminders(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Sistem'),
          _buildSettingTile(
            context,
            icon: Icons.delete_outline_rounded,
            title: 'Verileri Temizle',
            subtitle: 'Tüm uygulama verilerini sil',
            titleColor: Colors.redAccent,
            onTap: () => _showClearDataDialog(context),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ExamAI v1.0.0',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: isDarkMode ? Colors.white24 : Colors.black26,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF065F46),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                : const Color(0xFF10B981).withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: titleColor ?? (isDarkMode ? Colors.white : Colors.black87),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.outfit(
                  color: isDarkMode ? Colors.white38 : Colors.black45,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded,
                    color: isDarkMode ? Colors.white24 : Colors.black26)
                : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final authState = ref.watch(authProvider);
          return AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E293B)
                : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Şifre Değiştir',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldController,
                  decoration: InputDecoration(
                    labelText: 'Mevcut Şifre',
                    labelStyle: GoogleFonts.outfit(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newController,
                  decoration: InputDecoration(
                    labelText: 'Yeni Şifre',
                    labelStyle: GoogleFonts.outfit(),
                    prefixIcon: const Icon(Icons.vpn_key_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: true,
                ),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      authState.error!,
                      style: GoogleFonts.outfit(
                          color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: authState.isLoading ? null : () => context.pop(),
                child: Text('İptal',
                    style: GoogleFonts.outfit(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        if (oldController.text.isEmpty ||
                            newController.text.isEmpty) return;

                        if (newController.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Yeni şifre en az 6 haneli olmalıdır'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        final success = await ref
                            .read(authProvider.notifier)
                            .changePassword(
                                oldController.text, newController.text);
                        if (success && context.mounted) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Şifre başarıyla güncellendi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Güncelle',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verileri Temizle',
            style: GoogleFonts.outfit(color: Colors.redAccent)),
        content: Text(
          'Tüm uygulama verileriniz ve arşiviniz silinecektir. Bu işlem geri alınamaz.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal', style: GoogleFonts.outfit(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Implementation for data clearing would go here
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Her Şeyi Sil',
                style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
