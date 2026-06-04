import 'package:flutter/material.dart';

import 'auth_state.dart';
import 'module/module.dart';

// *** [do change classname] ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dodge Blocks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: FavioPalette.brandBright),
        useMaterial3: true,
      ),
      home: const _AppEntryPage(),
    );
  }
}

class _AppEntryPage extends StatelessWidget {
  const _AppEntryPage();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AppAuthState.instance,
      builder: (BuildContext context, String? authToken, Widget? child) {
        if (authToken != null && authToken.isNotEmpty) {
          return const MainShellPage();
        }
        return const LoginPage();
      },
    );
  }
}
