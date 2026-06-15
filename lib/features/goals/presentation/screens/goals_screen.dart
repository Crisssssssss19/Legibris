import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Metas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add, color: AppTheme.softBlack), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Streak Goal
            _buildGoalProgressCard(
              context,
              title: 'Meta diaria',
              rightLabel: '12 días de racha 🔥',
              description: 'Tu meta: 30 minutos al día',
              current: 45,
              target: 30,
              metric: 'min',
              message: '¡Meta superada! 🎉',
              progressColor: AppTheme.progressGreen,
            ),
            const SizedBox(height: 20),

            // Yearly Book Goal
            _buildGoalProgressCard(
              context,
              title: 'Meta de lectura',
              rightLabel: 'Este año v',
              description: 'Progreso anual de libros',
              current: 24,
              target: 40,
              metric: 'libros',
              message: '60% completado',
              progressColor: AppTheme.darkBrown,
            ),
            const SizedBox(height: 20),

            // Yearly Page Goal
            _buildGoalProgressCard(
              context,
              title: 'Meta de páginas',
              rightLabel: 'Este año v',
              description: 'Progreso anual de páginas',
              current: 5891,
              target: 10000,
              metric: 'páginas',
              message: '58% completado',
              progressColor: AppTheme.accentOrange,
            ),
            const SizedBox(height: 24),

            // Badges Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Logros',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver todos', style: TextStyle(color: AppTheme.darkBrown, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBadgesRow(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 3), // highlight Stats/Goals navigation
    );
  }

  Widget _buildGoalProgressCard(
    BuildContext context, {
    required String title,
    required String rightLabel,
    required String description,
    required int current,
    required int target,
    required String metric,
    required String message,
    required Color progressColor,
  }) {
    final progressVal = (current / target).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16)),
                Text(rightLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 4),
            Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              baseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  '$current',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28, color: AppTheme.softBlack),
                ),
                Text(' / $target $metric', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressVal,
              backgroundColor: AppTheme.lightGray,
              color: progressColor,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: AppTheme.progressGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesRow() {
    final badges = [
      {'icon': Icons.star, 'color': Colors.amber},
      {'icon': Icons.emoji_events, 'color': Colors.orange},
      {'icon': Icons.auto_stories, 'color': Colors.blue},
      {'icon': Icons.menu_book, 'color': Colors.teal},
      {'icon': Icons.local_fire_department, 'color': Colors.red},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: badges.map((badge) {
        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: (badge['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: (badge['color'] as Color), width: 2),
          ),
          child: Center(
            child: Icon(badge['icon'] as IconData, color: badge['color'] as Color, size: 28),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(BuildContext context, int index) {
    return BottomNavigationBar(
      currentIndex: index,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.darkBrown,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppTheme.warmWhite,
      onTap: (newIndex) {
        if (newIndex == 0) context.go('/home');
        if (newIndex == 1) context.go('/shelf');
        if (newIndex == 2) context.go('/shelf');
        if (newIndex == 3) context.go('/stats');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.shelves), label: 'Estantería'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Estadísticas'),
      ],
    );
  }
}
