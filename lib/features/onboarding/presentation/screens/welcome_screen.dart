import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo and Title
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBrown,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.book_rounded,
                        size: 64,
                        color: AppTheme.warmWhite,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Legibris',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.softBlack,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu biblioteca. Tus metas. Tu historia.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.darkBrown,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Core Features
              _buildFeatureRow(
                context,
                icon: Icons.search_rounded,
                title: 'Catálogo inteligente',
                description: 'Descubre libros y añade a tu lista de lectura.',
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                context,
                icon: Icons.shelves,
                title: 'Estantería personal',
                description: 'Organiza tus libros en colecciones personalizadas.',
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                context,
                icon: Icons.bar_chart_rounded,
                title: 'Estadísticas detalladas',
                description: 'Visualiza tu progreso y alcanza tus metas.',
              ),
              const SizedBox(height: 20),
              _buildFeatureRow(
                context,
                icon: Icons.flag_rounded,
                title: 'Metas y rachas',
                description: 'Mantén tu constancia y supera tus récords.',
              ),
              const Spacer(),
              // Action Buttons
              ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                child: const Text('Comenzar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/auth/login'),
                child: Text(
                  '¿Ya tienes cuenta? Inicia sesión',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.darkBrown,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context,
      {required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: AppTheme.darkBrown),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
