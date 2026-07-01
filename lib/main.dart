import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:moneytrackerapp/core/router/app_router.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';
import 'package:moneytrackerapp/core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(const ProviderScope(child: MoneyTrackerApp()));
}

class MoneyTrackerApp extends ConsumerWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final themeMode = settings?.themeMode ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'Mintly',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
