// =============================================================================
// ARQUIVO: lib/main.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/viewmodels/filme_viewmodel.dart';
import 'src/pages/home_page.dart';
import 'src/pages/busca_page.dart';
import 'src/pages/detalhes_page.dart';
import 'src/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CineListApp());
}

class CineListApp extends StatelessWidget {
  const CineListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FilmeViewModel(),
      child: MaterialApp(
        title: 'CineList',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.temaEscuro,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/busca': (context) => const BuscaPage(),
          '/detalhes': (context) => const DetalhesPage(),
        },
      ),
    );
  }
}
