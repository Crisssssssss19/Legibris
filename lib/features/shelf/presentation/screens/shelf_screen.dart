import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ShelfScreen extends StatefulWidget {
  const ShelfScreen({super.key});

  @override
  State<ShelfScreen> createState() => _ShelfScreenState();
}

class _ShelfScreenState extends State<ShelfScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _leidosBooks = [
    'Hábitos Atómicos',
    'Sapiens',
    'El monje que vendió su Ferrari',
    '1984',
    'Los 7 hábitos de la gente altamente efectiva',
    'El poder del AHORA',
    'Padre rico padre pobre',
    'Piense y hágase rico',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Estantería',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list_alt, color: AppTheme.softBlack), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search, color: AppTheme.softBlack), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add, color: AppTheme.softBlack), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.darkBrown,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.darkBrown,
          tabs: const [
            Tab(text: 'Leídos'),
            Tab(text: 'Leyendo'),
            Tab(text: 'Por leer'),
            Tab(text: 'Favoritos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShelfGrid(_leidosBooks),
          _buildShelfGrid(['Hábitos Atómicos']),
          _buildShelfGrid(['Sapiens', '1984']),
          _buildShelfGrid(['El monje que vendió su Ferrari', 'El poder del AHORA']),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, 2),
    );
  }

  Widget _buildShelfGrid(List<String> books) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.65,
      ),
      itemCount: books.length + 1, // Add "+ Add book" button at the end
      itemBuilder: (context, index) {
        if (index == books.length) {
          // Add Book cover placeholder
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.lightGray, style: BorderStyle.values[1], width: 2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 32, color: AppTheme.darkBrown),
                  SizedBox(height: 8),
                  Text('Añadir\nlibro', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.darkBrown)),
                ],
              ),
            ),
          );
        }

        final title = books[index];
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkBrown.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              // Cover Details Mock
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Wooden shelf decoration simulation at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  color: Colors.brown.shade800,
                ),
              )
            ],
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
        if (newIndex == 2) context.go('/shelf'); // Tab index mapping
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
