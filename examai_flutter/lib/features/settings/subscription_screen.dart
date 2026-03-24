import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/providers/providers.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isPro = user?.subscriptionTier == 'PRO';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF021A12) : const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Decorative Orbs
          const Positioned(
            top: -100,
            right: -100,
            child: GlowingOrb(size: 300, color: Color(0xFF065F46)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: GlowingOrb(size: 250, color: const Color(0xFF10B981).withOpacity(0.2)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        _buildHeroSection(isDark),
                        const SizedBox(height: 40),
                        _buildPlanComparison(isDark, isPro),
                        const SizedBox(height: 40),
                        _buildFeatureList(isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom CTA
          if (!isPro)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _buildUpgradeButton(context, ref),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => context.pop(),
          ),
          Text(
            'Üyelik Planları',
            style: GoogleFonts.outfit(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          'Limitleri Zorlayın 🚀',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Daha fazla sınav, daha hızlı üretim ve tam otomasyon için PRO\'ya geçin.',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPlanComparison(bool isDark, bool isPro) {
    return Row(
      children: [
        Expanded(
          child: _PlanCard(
            title: 'Ücretsiz',
            price: '₺0',
            subtitle: '/Sonsuza Dek',
            isActive: !isPro,
            features: const [
              'Günlük 3 Sınav',
              'Sınırlı AI Desteği',
              'Oto Pilot: Kapalı',
            ],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _PlanCard(
            title: 'Monthly PRO',
            price: '₺149',
            subtitle: '/Aylık',
            isActive: isPro,
            isPro: true,
            features: const [
              'Günlük 25 Sınav',
              'Gelişmiş AI Modelleri',
              '20 Aktif Oto Pilot',
            ],
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRO Avantajları',
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _FeatureTile(
          icon: Icons.flash_on_rounded,
          title: 'Işık Hızında Üretim',
          desc: 'Sınavlarınız öncelikli sırada hazırlanır.',
          isDark: isDark,
        ),
        _FeatureTile(
          icon: Icons.auto_mode_rounded,
          title: 'Tam Otomasyon',
          desc: 'Oto Pilot ile siz uyurken sınavlarınız hazır olur.',
          isDark: isDark,
        ),
        _FeatureTile(
            icon: Icons.history_edu_rounded,
            title: 'Sınırsız Arşiv',
            desc: 'Tüm geçmiş sınavlarınıza her zaman erişin.',
            isDark: isDark),
      ],
    );
  }

  Widget _buildUpgradeButton(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final iap = ref.read(iapServiceProvider);
          await iap.buySubscription();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(
          'Üyeliği PRO\'ya Yükselt',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final bool isActive;
  final List<String> features;
  final bool isDark;
  final bool isPro;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isActive,
    required this.features,
    required this.isDark,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'AKTİF',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(title,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price,
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: GoogleFonts.outfit(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(f,
                            style: GoogleFonts.outfit(
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontSize: 11))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isDark;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF10B981), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc,
                    style: GoogleFonts.outfit(
                        color: isDark ? Colors.white38 : Colors.black45,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
