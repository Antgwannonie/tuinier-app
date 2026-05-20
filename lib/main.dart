import 'package:flutter/material.dart';

import 'data/vegetable_repository.dart';
import 'screens/vegetable_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TuinierApp());
}

/// Later: auth StateProvider / Riverpod, thema per gebruiker, sync.
class TuinierApp extends StatelessWidget {
  const TuinierApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = VegetableRepository();

    return MaterialApp(
      title: 'Tuinier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF66BB6A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: VegetableListScreen(repository: repo),
    );
  }
}
