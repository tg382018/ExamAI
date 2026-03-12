import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../l10n/app_localizations.dart';

class StatusChip extends StatelessWidget {
  final ExamStatus status;
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    String text;
    bool loading = false;

    switch (status) {
      case ExamStatus.queued:
        color = Colors.orange;
        text = l10n.statusQueued;
        loading = true;
        break;
      case ExamStatus.generating:
        color = Colors.blue;
        text = l10n.statusGenerating;
        loading = true;
        break;
      case ExamStatus.ready:
        color = const Color(0xFF10B981);
        text = l10n.statusReady;
        break;
      case ExamStatus.failed:
        color = Colors.redAccent;
        text = l10n.statusFailed;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            SizedBox(
              width: compact ? 10 : 12,
              height: compact ? 10 : 12,
              child: CircularProgressIndicator(
                  strokeWidth: compact ? 1.5 : 2, color: color),
            ),
            SizedBox(width: compact ? 4 : 6),
          ],
          Text(
            text,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: const Color(0xFF94A3B8)),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF94A3B8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1E293B).withValues(alpha: 0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isDark ? null : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: isDark ? 40 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: child,
                ),
              )
            : Container(
                padding: padding ?? const EdgeInsets.all(24),
                child: child,
              ),
      ),
    );
  }
}

class GlowingOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double blur;

  const GlowingOrb({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 0.4,
    this.blur = 80,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (!isDark) return const SizedBox.shrink(); // Hide orbs in light mode
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
}
