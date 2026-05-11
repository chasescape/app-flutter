import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/services/advice_store.dart';

import 'details_logic.dart';

class DetailsPage extends StatelessWidget {
  DetailsPage({Key? key}) : super(key: key);

  final DetailsLogic logic = Get.put(DetailsLogic());

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveAdvice();
    final content = resolved?.content ?? '';
    final imagePath = resolved?.imagePath;
    final idLabel = resolved?.idLabel;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FA),
      appBar: AppBar(
        title: const Text('Style Advice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null && imagePath.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 480,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 18),
            ],
            _InfoCard(idLabel: idLabel),
            const SizedBox(height: 18),
            _AdviceContent(content: content),
          ],
        ),
      ),
    );
  }

  _ResolvedAdvice? _resolveAdvice() {
    final args = Get.arguments;
    if (args is AdvicePayload) {
      return _ResolvedAdvice.fromPayload(args);
    }
    if (args is Map) {
      final content = args['content']?.toString();
      final imagePath = args['imagePath']?.toString();
      final id = args['id']?.toString();
      if (content != null) {
        return _ResolvedAdvice(
          content: content,
          imagePath: imagePath,
          idLabel: id,
        );
      }
    }
    final latest = AdviceStore.latest.value;
    if (latest != null) {
      return _ResolvedAdvice.fromPayload(latest);
    }
    return null;
  }
}

class _ResolvedAdvice {
  final String content;
  final String? imagePath;
  final String? idLabel;

  _ResolvedAdvice({required this.content, this.imagePath, this.idLabel});

  factory _ResolvedAdvice.fromPayload(AdvicePayload payload) {
    return _ResolvedAdvice(
      content: payload.content,
      imagePath: payload.imagePath,
      idLabel: payload.createdAt.millisecondsSinceEpoch.toString(),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String? idLabel;

  const _InfoCard({this.idLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Outfit Advice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const Spacer(),
              if (idLabel != null)
                Text(
                  'ID $idLabel',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9A9A9A),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TagChip(text: '#summer'),
              _TagChip(text: '#casual'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _MetaCard(
                  title: 'Occasion',
                  value: 'Casual Outing',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _MetaCard(
                  title: 'Season',
                  value: 'Spring',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;

  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFEE7FA0),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetaCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A8A)),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdviceContent extends StatelessWidget {
  final String content;

  const _AdviceContent({required this.content});

  @override
  Widget build(BuildContext context) {
    final sections = _limitSections(_parseSections(content));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sections.isNotEmpty)
          ...sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _SectionCard(section: section),
              )),
        if (sections.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              _cleanMarkdown(content),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),
      ],
    );
  }

  List<_Section> _limitSections(List<_Section> sections) {
    if (sections.isEmpty) return sections;
    final first = sections.first;
    final items = first.items.isNotEmpty ? [first.items.first] : const <String>[];
    return [
      _Section(title: first.title, items: items),
    ];
  }

  List<_Section> _parseSections(String text) {
    final lines = text.split('\n');
    final sections = <_Section>[];
    _Section? current;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('###')) {
        current = _Section(
          title: _cleanMarkdown(line.replaceFirst('###', '').trim()),
          items: [],
        );
        sections.add(current);
        continue;
      }

      final bullet = _normalizeBullet(line);
      if (bullet != null) {
        current ??= _Section(title: 'Tips', items: []);
        if (!sections.contains(current)) {
          sections.add(current);
        }
        current.items.add(_cleanMarkdown(bullet));
        continue;
      }

      if (current == null) {
        current = _Section(title: 'Overview', items: []);
        sections.add(current);
      }
      current.items.add(_cleanMarkdown(line));
    }

    return sections;
  }

  String? _normalizeBullet(String line) {
    if (line.startsWith('- ')) return line.substring(2).trim();
    if (line.startsWith('* ')) return line.substring(2).trim();
    if (line.startsWith('• ')) return line.substring(2).trim();
    if (RegExp(r'^\d+\.?\s+').hasMatch(line)) {
      return line.replaceFirst(RegExp(r'^\d+\.?\s+'), '').trim();
    }
    return null;
  }

  String _cleanMarkdown(String input) {
    var text = input;
    text = text.replaceAll(RegExp(r'[#*_`]+'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }
}

class _SectionCard extends StatelessWidget {
  final _Section section;

  const _SectionCard({required this.section});

  IconData _iconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('shoe')) return Icons.shopping_bag_outlined;
    if (lower.contains('accessor')) return Icons.watch_later_outlined;
    if (lower.contains('top')) return Icons.checkroom_outlined;
    if (lower.contains('bottom') || lower.contains('pants')) {
      return Icons.replay_outlined;
    }
    if (lower.contains('dress')) return Icons.auto_awesome_outlined;
    if (lower.contains('color')) return Icons.palette_outlined;
    if (lower.contains('style')) return Icons.style_outlined;
    if (lower.contains('summary') || lower.contains('overview')) {
      return Icons.notes_outlined;
    }
    return Icons.lightbulb_outline;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _iconForTitle(section.title);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Color(0xFFEE7FA0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...section.items.asMap().entries.map(
                (entry) => Column(
                  children: [
                    if (entry.key != 0)
                      const Divider(height: 20, color: Color(0xFFF0DFE7)),
                    _AdviceItem(
                      text: entry.value,
                      index: entry.key + 1,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _Section {
  final String title;
  final List<String> items;

  _Section({required this.title, required this.items});
}

class _AdviceItem extends StatelessWidget {
  final String text;
  final int index;

  const _AdviceItem({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    final parts = text.split(':');
    final hasLabel = parts.length > 1 && parts.first.trim().length <= 16;
    final label = hasLabel ? parts.first.trim() : null;
    final body = hasLabel ? parts.sublist(1).join(':').trim() : text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEE7FA0),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            index.toString(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              if (label != null) const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF4A4A4A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
