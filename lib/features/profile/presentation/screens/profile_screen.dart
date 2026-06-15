import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner & Avatar Header Area
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Banner background
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AppTheme.darkBrown,
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1507842217343-583bb7270b66?q=80&w=600'),
                      fit: BoxFit.cover,
                      opacity: 0.4,
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/home'),
                  ),
                ),
                // Avatar image positioning
                Positioned(
                  bottom: -50,
                  left: 24,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.beigeLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.beigeLight, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: AppTheme.lightGray,
                      backgroundImage: NetworkImage('https://api.dicebear.com/7.x/adventurer/svg?seed=cris_lector'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // Profile info (Username & Bio)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cris Lector',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '@cris_lector',
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.darkBrown),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Editar perfil', style: TextStyle(color: AppTheme.darkBrown)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Apasionado de la ciencia ficción, la historia y el crecimiento personal. Leyendo un libro a la vez.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Reading Stats overview row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('24', 'Leídos'),
                      _buildMiniStat('1', 'Leyendo'),
                      _buildMiniStat('12', 'Racha días'),
                      _buildMiniStat('5.8k', 'Páginas'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Unlocked achievements display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Logros Recientes',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _buildAchievementsGrid(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 3), // Select stats/profile nav mapping
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkBrown),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context) {
    final achievements = [
      {'title': 'Primer Libro', 'desc': 'Terminaste tu primer lectura.', 'icon': Icons.star, 'color': Colors.amber},
      {'title': 'Racha Suprema', 'desc': 'Leíste 10 días seguidos.', 'icon': Icons.local_fire_department, 'color': Colors.red},
      {'title': 'Gran Lector', 'desc': 'Llegaste a 10 libros terminados.', 'icon': Icons.emoji_events, 'color': Colors.orange},
      {'title': 'Erudito', 'desc': 'Leíste más de 5,000 páginas.', 'icon': Icons.menu_book, 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final ach = achievements[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(ach['icon'] as IconData, color: ach['color'] as Color, size: 24),
                const SizedBox(height: 8),
                Text(
                  ach['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  ach['desc'] as String,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
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
