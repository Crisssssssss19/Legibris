import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive local cache storage
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cached_books');

  // Initialize Supabase (Use standard environment configurations)
  // Ensure keys are set up in your env configurations before launching
  await Supabase.initialize(
    url: String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://uyjznrkremalrpwmzoyh.supabase.co'),
    anonKey: String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'sb_publishable_8uMcAyJpWA1ldyMgrOXAOg_IpKIq-Qr'),
  );

  runApp(
    const ProviderScope(
      child: LegibrisApp(),
    ),
  );
}

class LegibrisApp extends ConsumerWidget {
  const LegibrisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Legibris',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Dynamically switches between light and dark modes
      routerConfig: appRouter,
    );
  }
}
