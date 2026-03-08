import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showPolicyDialog(BuildContext context, String title, String content) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.commonClose,
                style: const TextStyle(
                    color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registerErrorTerms)),
        );
        return;
      }

      final success = await ref.read(authProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );

      if (success) {
        if (mounted) {
          context.push('/verify-email', extra: _emailController.text.trim());
        }
      } else {
        if (mounted) {
          final error = ref.read(authProvider).error;
          String message = l10n.registerGenericError;

          if (error != null) {
            if (error.contains('User already exists')) {
              message = l10n.registerErrorConflict;
            } else if (error.contains('Email already in use')) {
              message = l10n.registerErrorConflict;
            } else {
              message = error;
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
            ),
          ),
          // Animated Blobs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      l10n.registerTitle,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Name Field
                    CustomTextField(
                      controller: _nameController,
                      label: l10n.registerName,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value?.isEmpty ?? true
                          ? l10n.registerErrorName
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: l10n.registerEmail,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return l10n.registerErrorEmail;
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value!)) {
                          return l10n.registerErrorEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: l10n.registerPassword,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true)
                          return l10n.registerErrorPassword;
                        if (value!.length < 6)
                          return l10n.registerErrorPassword;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: l10n.registerConfirmPassword,
                      prefixIcon: Icons.lock_reset,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return l10n.registerErrorMatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Terms Checkbox
                    _TermsCheckbox(
                      value: _acceptTerms,
                      onChanged: (val) =>
                          setState(() => _acceptTerms = val ?? false),
                      onTermsTap: () => _showPolicyDialog(
                        context,
                        l10n.termsTitle,
                        l10n.termsContent,
                      ),
                      onPrivacyTap: () => _showPolicyDialog(
                        context,
                        l10n.privacyTitle,
                        l10n.privacyContent,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Register Button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DD4BF),
                        foregroundColor: const Color(0xFF0F172A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ).copyWith(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.disabled)) {
                            return const Color(0xFF2DD4BF)
                                .withValues(alpha: 0.5);
                          }
                          return const Color(0xFF2DD4BF);
                        }),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F172A),
                              ),
                            )
                          : Text(
                              l10n.registerButton,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.registerHaveAccount.split('?').first + '?',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            l10n.registerHaveAccount.split('?').last.trim(),
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF2DD4BF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF2DD4BF) : Colors.transparent,
              border: Border.all(
                color:
                    value ? const Color(0xFF2DD4BF) : const Color(0xFF475569),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Color(0xFF0F172A))
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
              children: [
                TextSpan(text: l10n.registerTermsPrefix),
                TextSpan(
                  text: l10n.registerTermsLink,
                  style: const TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                TextSpan(text: l10n.registerAnd),
                TextSpan(
                  text: l10n.registerPrivacyLink,
                  style: const TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                ),
                if (l10n.registerTermsSuffix.isNotEmpty)
                  TextSpan(text: l10n.registerTermsSuffix),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
