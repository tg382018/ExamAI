import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _loading = false;
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
    if (_codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen 6 haneli kodu girin.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(authProvider.notifier)
          .verify(widget.email, _codeController.text);
      if (mounted) context.go('/my-exams');
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

  void _resend() async {
    if (_secondsRemaining > 0) return;

    try {
      await ref.read(authProvider.notifier).resendCode(widget.email);
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni kod gönderildi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';

        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map && data.containsKey('error')) {
            errorMessage = data['error'];
            // Özel olarak "Geçersiz doğrulama kodu" gelirse daha kısa yapalım
            if (errorMessage == 'Geçersiz doğrulama kodu') {
              errorMessage = 'Kod yanlış';
            }
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

  @override
  Widget build(BuildContext context) {
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
                    loading: _loading,
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
              child: _Blob(
                color: const Color(0xFF10B981), // Emerald
                size: 300,
                opacity: 0.4,
              ),
            ),
            Positioned(
              bottom: -50 - (30 * animation.value),
              right: -50 - (20 * animation.value),
              child: _Blob(
                color: const Color(0xFF3B82F6), // Blue
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
            color: color.withOpacity(opacity),
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
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFA7F3D0)],
          ).createShader(bounds),
          child: Text(
            'E-posta Doğrulama',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$email adresine gönderdiğimiz 6 haneli kodu girin.',
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFF0F172A).withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.1)),
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
                      ? 'Kodu tekrar gönder'
                      : 'Tekrar gönder (${(secondsRemaining ~/ 60).toString().padLeft(2, '0')}:${(secondsRemaining % 60).toString().padLeft(2, '0')})',
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
              color: const Color(0xFF10B981).withOpacity(0.4),
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
                  'Doğrula',
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
