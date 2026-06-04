import 'package:flutter/material.dart';
import 'package:hotou/hotou/features/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HotoU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F7C55),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _StartupGate(),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 260), () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const LoginPage(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF7DF),
      body: Center(
        child: Text(
          'HotoU',
          style: TextStyle(
            color: Color(0xFF263D32),
            fontSize: 32,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
