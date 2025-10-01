
// ========================================
// main.dart (VERSION MISE À JOUR)
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'config/dependencies.dart';
import 'config/environment.dart';
import 'config/routes.dart';

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
    return MaterialApp.router(
      title: 'GESTORE Desktop',
      debugShowCheckedModeBanner: false,

      // Configuration du router
      routerConfig: goRouter,

      // Thème clair
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',

        // Personnalisation des composants
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Thème sombre
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      themeMode: ThemeMode.system,
    );
  }
}