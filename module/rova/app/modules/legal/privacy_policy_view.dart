import 'package:flutter/material.dart';
import 'package:rova/rova/app/modules/legal/agreement_view.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AgreementPage(
      type: AgreementType.privacy,
    );
  }
}
