import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Inicio',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: AppTheme.softBlack),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.softBlack),
            onPressed: () => context.go('/shelf'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Reading Section
            Text(
              'Lectura actual',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildCurrentReadingCard(context),
            const SizedBox(height: 24),

            // Daily Goal
            _buildDailyGoalCard(context),
            const SizedBox(height: 24),

            // Monthly Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumen del mes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => context.go('/stats'),
                  child: const Text('Este mes v', style: TextStyle(color: AppTheme.darkBrown)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(context),
            const SizedBox(height: 24),

            // Continue Reading
            Text(
              'Continuar leyendo',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildContinueReadingRow(),
            const SizedBox(height: 80), // bottom space
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 0),
    );
  }

  Widget _buildCurrentReadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Image Mock
            Container(
              width: 70,
              height: 105,
              decoration: BoxDecoration(
                color: AppTheme.darkBrown.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Hábitos\nAtómicos',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábitos Atómicos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('James Clear', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progreso', style: Theme.of(context).textTheme.bodyMedium),
                      const Text('68%', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.softBlack)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(
                    value: 0.68,
                    backgroundColor: AppTheme.lightGray,
                    color: AppTheme.progressGreen,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkBrown,
                      minimumSize: const Size.fromHeight(40),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Continuar leyendo', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '12 días de racha',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('¡Sigue así!', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                bool isCompleted = day != 'S' && day != 'D'; // Mock: Completed weekdays
                return Column(
                  children: [
                    Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCompleted ? AppTheme.progressGreen : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.lightGray, width: 2),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(context, title: '24', subtitle: 'Libros leídos', change: '↗ 2 vs mes pasado'),
        _buildStatCard(context, title: '5,891', subtitle: 'Páginas leídas', change: '↗ 112 vs mes pasado'),
        _buildStatCard(context, title: '14h 32m', subtitle: 'Tiempo de lectura', change: ''),
        _buildStatCard(context, title: '196', subtitle: 'Páginas/día promedio', change: ''),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context,
      {required String title, required String subtitle, required String change}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, color: AppTheme.softBlack),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
            if (change.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                change,
                style: const TextStyle(fontSize: 10, color: AppTheme.progressGreen, fontWeight: FontWeight.bold),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingRow() {
    final books = [
      'El monje que vendió su Ferrari',
      'Piense y hágase rico',
      'El poder del AHORA'
    ];
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppTheme.darkBrown.withOpacity(0.5 + (index * 0.15)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.lightGray),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  books[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
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
        if (newIndex == 2) context.go('/stats');
        if (newIndex == 3) context.go('/goals');
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
