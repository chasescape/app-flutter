import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/modules/chat/chat_view.dart';
import 'package:riko/riko/app/modules/home/home_view.dart';
import 'package:riko/riko/app/modules/profile/profile_view.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavPage extends StatefulWidget {
  const NavPage({Key? key}) : super(key: key);

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _index = 0;
  static const String _agreementKey = 'user_agreement_accepted';

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      if (args['initialIndex'] is int) {
        _index = args['initialIndex'] as int;
      } else if (args['tab'] == 'chat') {
        _index = 1;
      } else if (args['tab'] == 'profile') {
        _index = 2;
      } else if (args['tab'] == 'home') {
        _index = 0;
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAgreement();
    });
  }

  Future<void> _checkAgreement() async {
    final prefs = await SharedPreferences.getInstance();
    final agreed = prefs.getBool(_agreementKey) ?? false;
    if (!mounted || agreed) return;
    _showAgreementDialog(context);
  }

  void _showAgreementDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agreement Required'),
        content: const Text(
          'Please read and accept the Terms and Privacy Policy to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool(_agreementKey, true);
              if (mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Agree'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (int value) => setState(() => _index = value),
        selectedItemColor: const Color(0xFFEE7FA0),
        unselectedItemColor: const Color(0xFF9E9E9E),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style),
            label: 'Ask Riko',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
