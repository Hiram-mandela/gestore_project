import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'config/dependencies.dart';
import 'config/environment.dart';

void main() async {
  // S'assurer que les bindings Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Configurer l'injection de dépendances
  await configureDependencies();

  // Logger pour le démarrage
  final logger = getIt<Logger>();
  logger.i('🚀 Démarrage de GESTORE Desktop');
  logger.i('📡 Environnement: ${AppEnvironment.current.name}');
  logger.i('🌐 API Base URL: ${AppEnvironment.current.apiBaseUrl}');

  // Lancer l'application
  runApp(
    const ProviderScope(
      child: GestoreApp(),
    ),
  );
}

/// Application principale GESTORE
class GestoreApp extends StatelessWidget {
  const GestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GESTORE Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

/// Écran de démarrage temporaire
/// Sera remplacé par un vrai splash screen dans la prochaine étape
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final logger = getIt<Logger>();

    try {
      // Simuler le chargement initial
      await Future.delayed(const Duration(seconds: 2));

      logger.i('✅ Application initialisée avec succès');

      // TODO: Naviguer vers l'écran de login ou home selon l'authentification
      // Pour l'instant, on reste sur le splash
    } catch (e, stackTrace) {
      logger.e('❌ Erreur lors de l\'initialisation', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Icon(
                Icons.store,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              // Nom de l'application
              Text(
                'GESTORE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Système de Gestion Intégrée',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              // Indicateur de chargement
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Version
              Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}