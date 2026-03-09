import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/theme/app_theme.dart';
import 'core/api/router.dart';
import 'core/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Firebase.initializeApp() will fail until google-services.json/GoogleService-Info.plist are added.
  // We wrap it for now to allow development to proceed.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed (expected if config missing): $e');
  }

  runApp(
    const ProviderScope(
      child: ExamAIApp(),
    ),
  );
}

class ExamAIApp extends ConsumerWidget {
  const ExamAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ExamAI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
        Locale('ar'),
      ],
    );
  }
}
