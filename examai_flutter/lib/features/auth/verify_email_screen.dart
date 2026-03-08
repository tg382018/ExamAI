import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/providers.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  late AnimationController _animationController;
  Timer? _resendTimer;
  int _secondsRemaining = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = 120);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _animationController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _verify() async {
    final l10n = AppLocalizations.of(context)!;

    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.verifyErrorInvalid)),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .verify(widget.email, _codeController.text);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifySuccess)),
        );
        context.go('/my-exams');
      }
    } else {
      if (mounted) {
        final error = ref.read(authProvider).error;
        String errorMessage = l10n.verifyErrorInvalid;

        if (error != null) {
          if (error.contains('Geçersiz doğrulama kodu')) {
            errorMessage = l10n.verifyErrorInvalid;
          } else {
            errorMessage = error;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _resend() async {
    final l10n = AppLocalizations.of(context)!;
    if (_secondsRemaining > 0) return;

    final success =
        await ref.read(authProvider.notifier).resendCode(widget.email);

    if (success) {
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifyResend)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.verifyGenericError),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: Stack(
        children: [
          _BackgroundBlobs(animation: _animationController),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(onTap: () => context.pop()),
                  ),
                  const SizedBox(height: 40),
                  _HeaderSection(email: widget.email),
                  const SizedBox(height: 30),
                  _VerifyForm(
                    codeController: _codeController,
                    loading: authState.isLoading,
                    onSubmit: _verify,
                    onResend: _resend,
                    secondsRemaining: _secondsRemaining,
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
              top: -100 + (30 * animation.value),
              left: -50 + (20 * animation.value),
              child: const _Blob(
                color: Color(0xFF10B981), // Emerald
                size: 300,
                opacity: 0.4,
              ),
            ),
            Positioned(
              bottom: -50 - (30 * animation.value),
              right: -50 - (20 * animation.value),
              child: const _Blob(
                color: Color(0xFF3B82F6), // Blue
                size: 250,
                opacity: 0.4,
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

  const _Blob({required this.color, required this.size, required this.opacity});

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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String email;
  const _HeaderSection({required this.email});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFA7F3D0)],
          ).createShader(bounds),
          child: Text(
            l10n.verifyTitle,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.verifyDesc(email),
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}

class _VerifyForm extends StatelessWidget {
  final TextEditingController codeController;
  final bool loading;
  final VoidCallback onSubmit;
  final VoidCallback onResend;
  final int secondsRemaining;

  const _VerifyForm({
    required this.codeController,
    required this.loading,
    required this.onSubmit,
    required this.onResend,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.1)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF0F172A).withValues(alpha: 0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _VerifyButton(onTap: onSubmit, loading: loading),
              const SizedBox(height: 20),
              TextButton(
                onPressed: secondsRemaining == 0 ? onResend : null,
                child: Text(
                  secondsRemaining == 0
                      ? l10n.verifyResend
                      : l10n.verifyWait(secondsRemaining),
                  style: GoogleFonts.outfit(
                    color: secondsRemaining == 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool loading;

  const _VerifyButton({required this.onTap, required this.loading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  l10n.verifyButton,
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
