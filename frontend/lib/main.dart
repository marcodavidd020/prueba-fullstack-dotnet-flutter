import 'package:flutter/material.dart';

void main() {
  runApp(const SolCatalogApp());
}

class SolCatalogApp extends StatelessWidget {
  const SolCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Catálogo de productos',
      home: Scaffold(
        body: Center(child: Text('Sol Catalog')),
      ),
    );
  }
}
