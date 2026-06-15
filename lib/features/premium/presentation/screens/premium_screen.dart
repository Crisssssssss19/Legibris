import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  String get _getPlatformGateway() {
    if (kIsWeb) return 'Web (PayPal o Mercado Pago)';
    try {
      if (Platform.isAndroid) return 'Google Play Billing';
      if (Platform.isIOS) return 'Apple In-App Purchases';
    } catch (_) {}
    return 'PayPal / Mercado Pago';
  }

  @override
  Widget build(BuildContext context) {
    final gateway = _getPlatformGateway();
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.softBlack),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Legibris Premium', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softBlack)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 72),
            const SizedBox(height: 16),
            Text(
              'Lleva tu lectura al siguiente nivel',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Desbloquea funciones de Inteligencia Artificial avanzadas, estadísticas completas y temas exclusivos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            // Premium features list
            _buildFeatureTile(context, icon: Icons.psychology_outlined, title: 'Asistente de lectura IA', desc: 'Resúmenes, comparaciones y recomendaciones personalizadas.'),
            const SizedBox(height: 16),
            _buildFeatureTile(context, icon: Icons.insights, title: 'Estadísticas Avanzadas', desc: 'Acceso a heatmaps de lectura interactivos e informes exportables.'),
            const SizedBox(height: 16),
            _buildFeatureTile(context, icon: Icons.palette_outlined, title: 'Temas Exclusivos', desc: 'Personaliza tu aplicación con estilos y tipografías premium.'),
            const SizedBox(height: 40),
            // Payment Subscriptions
            Card(
              child: ListTile(
                title: const Text('Plan Mensual', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Cancela cuando quieras'),
                trailing: const Text('\$2.99 / mes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkBrown)),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: AppTheme.darkBrown.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppTheme.darkBrown, width: 2),
              ),
              child: ListTile(
                title: const Text('Plan Anual', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ahorra 20% en tu lectura'),
                trailing: const Text('\$27.99 / año', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkBrown)),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Método de pago actual: $gateway',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkBrown),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: Text('Suscribirse con $gateway'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(BuildContext context, {required IconData icon, required String title, required String desc}) {
    return Row(
      children: [
        Icon(icon, size: 28, color: AppTheme.darkBrown),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
              Text(desc, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }
}
