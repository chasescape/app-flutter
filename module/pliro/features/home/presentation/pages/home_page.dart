import 'package:flutter/material.dart';
import 'package:pliro/pliro/features/home/presentation/pages/home_page_content.dart';

/// Home page - main entry point when opened outside the tab shell.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePageContent(),
    );
  }
}
