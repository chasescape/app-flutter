import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'details_logic.dart';

class DetailsArgs {
  const DetailsArgs({
    required this.title,
    this.subtitle,
    this.date,
    this.extra,
  });

  final String title;
  final String? subtitle;
  final String? date;
  final Map<String, Object?>? extra;
}

class DetailsPage extends StatelessWidget {
  DetailsPage({Key? key}) : super(key: key);

  final DetailsLogic logic = Get.put(DetailsLogic());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final DetailsArgs? item = args is DetailsArgs ? args : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFBBF24)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: item == null
          ? const Center(
              child: Text('No data',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
            )
          : _DetailBody(item: item),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item});

  final DetailsArgs item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFDE68A).withValues(alpha: 0.25),
              width: 1.5,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.50),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.20),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFFFFF7ED)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Info section
        _InfoTile(label: 'Description', value: item.subtitle ?? ''),
        const SizedBox(height: 12),
        _InfoTile(label: 'Date', value: item.date ?? ''),
        if ((item.extra ?? const {}).isNotEmpty) ...[
          const SizedBox(height: 12),
          ...(item.extra ?? const {}).entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InfoTile(label: e.key, value: e.value.toString()),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF78350F).withValues(alpha: 0.30),
          width: 1.5,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900.withValues(alpha: 0.80),
            Colors.black.withValues(alpha: 0.80),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFBBF24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
