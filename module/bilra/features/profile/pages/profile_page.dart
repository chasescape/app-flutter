import 'package:flutter/material.dart';
import 'package:bilra/bilra/features/home/widgets/profile_content.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: ProfileContent(embeddedInHome: false),
      ),
    );
  }
}
