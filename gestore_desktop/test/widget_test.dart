import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gestore_desktop/main.dart';

void main() {
  testWidgets('Application démarre correctement', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GestoreApp(),
      ),
    );

    // Vérifier que le splash screen s'affiche
    expect(find.text('GESTORE'), findsOneWidget);
    expect(find.text('Système de Gestion Intégrée'), findsOneWidget);
    expect(find.text('Chargement...'), findsOneWidget);
  });

  testWidgets('Splash screen affiche le logo', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GestoreApp(),
      ),
    );

    // Vérifier que l'icône du store est présente
    expect(find.byIcon(Icons.store), findsOneWidget);
  });

  testWidgets('Version est affichée', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GestoreApp(),
      ),
    );

    // Vérifier que la version est affichée
    expect(find.text('Version 1.0.0'), findsOneWidget);
  });
}