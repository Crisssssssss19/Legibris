import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.beigeLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.softBlack),
          onPressed: () => context.go('/stats'),
        ),
        title: Text(
          'Calendario',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Calendar Month Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
                Text(
                  'Julio 2024',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18),
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 12),
            // Days of the week headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                  .map((d) => SizedBox(
                        width: 40,
                        child: Text(d, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Grid of days
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.8,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                // Mock: Put book cover images on certain read days (e.g. 2, 8, 10, 13, 19, 22, 27, 30)
                final readDays = [2, 8, 10, 13, 19, 22, 27, 30];
                final hasBook = readDays.contains(day);

                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.warmWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.lightGray),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: hasBook ? AppTheme.darkBrown : AppTheme.softBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasBook)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.darkBrown,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Icon(Icons.book_rounded, size: 12, color: Colors.white),
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.green, 'Libro completado'),
                _buildLegendItem(Colors.blue, 'Libro en progreso'),
                _buildLegendItem(Colors.orange, 'Meta alcanzada'),
              ],
            ),
            const SizedBox(height: 30),
            // Month total summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.auto_stories, color: AppTheme.darkBrown, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Has leído 3 libros, 729 páginas y 21h 32m en este mes.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, color: AppTheme.softBlack)),
      ],
    );
  }
}
