// ========================================
// lib/main.dart
// Point d'entrée de l'application GESTORE
// VERSION MISE À JOUR avec nouveau thème
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:logger/logger.dart';
import 'config/dependencies.dart';
import 'config/routes.dart';
import 'shared/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les dépendances
  await configureDependencies();

  // Initialiser les locales pour formatage des dates
  await initializeDateFormatting('fr_FR', null);

  // Logger de démarrage
  final logger = Logger();
  logger.i('🚀 GESTORE démarré avec succès');
  logger.i('📱 Version: 1.0.0');
  logger.i('🌍 Locale: fr_FR');

  runApp(
    const ProviderScope(
      child: GestoreApp(),
    ),
  );
}

/// Widget racine de l'application
class GestoreApp extends StatelessWidget {
  const GestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configuration de base
      title: 'GESTORE - Gestion Intégrée',
      debugShowCheckedModeBanner: false,

      // Router
      routerConfig: goRouter,

      // Thèmes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localisation
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Titre de l'app dans la barre de titre (desktop)
      onGenerateTitle: (context) => 'GESTORE - Gestion Intégrée',
    );
  }
}