import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text('ExamAI', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              Text('AI ile sınavlarını anında oluştur.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70)),
              const Spacer(),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'E-posta'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(hintText: 'Şifre'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Giriş Yap'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Hesabın yok mu? Kayıt Ol'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
