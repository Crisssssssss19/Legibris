import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppTheme.softBlack),
            onPressed: () => context.go('/stats/calendar'),
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: AppTheme.softBlack), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.darkBrown,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.darkBrown,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Tendencias'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildResumenTab(context),
          _buildTendenciasTab(context),
          _buildMetasTab(context),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 3),
    );
  }

  Widget _buildResumenTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Overview Cards
          _buildInfoCard(
            context,
            title: 'Has leído 24 libros',
            subtitle: '↗ 2 libros',
            child: const Icon(Icons.trending_up, color: AppTheme.progressGreen, size: 32),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: 'Has leído 5,891 páginas',
            subtitle: '↗ 112 páginas este mes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Promedio', style: Theme.of(context).textTheme.bodyMedium),
                const Text('196 pág/mes', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Top Categories Pie Chart Mockup
          Text(
            'Tus categorías principales',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Circle representation of pie chart
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.darkBrown, width: 12),
                    ),
                    child: const Center(
                      child: Text('3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• Ficción (45%)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('• Historia (30%)', style: TextStyle(color: Colors.grey)),
                        Text('• Negocios (25%)', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Achievements Banner
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Estás en el top 10%!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 16, color: Colors.amber.shade900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Has leído más que el 90% de los lectores de Legibris.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTendenciasTab(BuildContext context) {
    return const Center(child: Text('Gráficos de Tendencias Anuales (Históricos)'));
  }

  Widget _buildMetasTab(BuildContext context) {
    return const Center(child: Text('Configuración de Metas de Lectura'));
  }

  Widget _buildInfoCard(BuildContext context,
      {required String title, required String subtitle, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.progressGreen, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            child,
          ],
        ),
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
