// ========================================
// features/authentication/presentation/widgets/logo_widget.dart
// VERSION CORRIGÉE (sans deprecated)
// ========================================
import 'package:flutter/material.dart';

/// Widget du logo GESTORE
class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icône
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.store,
            size: size,
            color: Colors.white,
          ),
        ),

        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'GESTORE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ],
    );
  }
}