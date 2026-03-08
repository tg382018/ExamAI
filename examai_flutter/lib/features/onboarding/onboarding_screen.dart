import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await ref.read(preferencesServiceProvider).setOnboardingSeen();
      ref.invalidate(onboardingSeenProvider);
      if (mounted) {
        context.go('/register');
      }
    }
  }

  void _onLogin() async {
    await ref.read(preferencesServiceProvider).setOnboardingSeen();
    ref.invalidate(onboardingSeenProvider);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          // Background Blobs
          _BackgroundBlobs(animation: _animationController),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  fit: BoxFit.contain,
                  color: Colors.white.withValues(alpha: 0.8),
                  colorBlendMode: BlendMode.modulate,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _OnboardingSlide(
                        title: l10n.onboardingTitle1,
                        description: l10n.onboardingDesc1,
                        imageUrl:
                            'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?q=80&w=1000&auto=format&fit=crop',
                        isFirst: true,
                      ),
                      _OnboardingSlide(
                        title: l10n.onboardingTitle2,
                        description: l10n.onboardingDesc2,
                        imageUrl:
                            'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?q=80&w=1000&auto=format&fit=crop',
                        isFirst: false,
                      ),
                    ],
                  ),
                ),

                // Pagination and Button Container
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PaginationDots(currentPage: _currentPage),
                      const SizedBox(height: 32),
                      _OnboardingButton(
                        onTap: _onNext,
                        isLast: _currentPage == 1,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _onLogin,
                        child: Text(
                          l10n.onboardingLoginLink,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  final Animation<double> animation;
  const _BackgroundBlobs({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + (20 * animation.value),
              left: -100 + (30 * animation.value),
              child: const _Blob(
                color: Color(0xFF7C3AED),
                size: 300,
                opacity: 0.4,
              ),
            ),
            Positioned(
              bottom: -50 - (20 * animation.value),
              right: -50 - (30 * animation.value),
              child: const _Blob(
                color: Color(0xFF2563EB),
                size: 250,
                opacity: 0.4,
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: MediaQuery.of(context).size.width * 0.3,
              child: const _Blob(
                color: Color(0xFFDB2777),
                size: 200,
                opacity: 0.3,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Blob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: 100,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final bool isFirst;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Illustration Container
            Transform.rotate(
              angle: isFirst ? -0.08 : 0.08,
              child: Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 35,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Glassmorphism Text Card
            _GlassCard(
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFBFDBFE)],
                    ).createShader(bounds),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: const Color(0xFF94A3B8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PaginationDots extends StatelessWidget {
  final int currentPage;
  const _PaginationDots({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentPage == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _OnboardingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLast;

  const _OnboardingButton({
    required this.onTap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    const gradientStart = [Color(0xFF6366F1), Color(0xFFA855F7)];
    const gradientEnd = [Color(0xFF10B981), Color(0xFF3B82F6)];

    final gradient =
        LinearGradient(colors: isLast ? gradientEnd : gradientStart);

    final label = isLast ? l10n.onboardingStart : l10n.onboardingNext;
    final shadowColor = isLast
        ? const Color(0xFF10B981).withValues(alpha: 0.4)
        : const Color(0xFF7C3AED).withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
