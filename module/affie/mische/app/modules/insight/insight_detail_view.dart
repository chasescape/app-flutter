import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../emotion/emotion_models.dart';
import '../../widgets/mische_background.dart';

class InsightDetailPage extends StatelessWidget {
  const InsightDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final insight = Get.arguments as Insight;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: MischeBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, insight),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Analysis',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(insight.details, style: const TextStyle(color: Color(0xFFB0B0B6), height: 1.5)),
                      const SizedBox(height: 16),
                      const Text('Recommendations',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...insight.tips.map((tip) => _buildTip(insight, tip)).toList(),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: insight.gradient.last,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Got it!'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Insight insight) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: insight.userImagePath != null
              ? Image.file(
                  File(insight.userImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(insight.imageUrl, fit: BoxFit.cover);
                  },
                )
              : Image.network(insight.imageUrl, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: topInset + 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: insight.gradient),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('AI Insight',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
              const SizedBox(height: 8),
              Text(insight.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(Insight insight, String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: insight.gradient),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('•', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip, style: const TextStyle(color: Color(0xFFB0B0B6), fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
