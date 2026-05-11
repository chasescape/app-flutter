import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class NailCopyResult {
  const NailCopyResult({
    required this.highlights,
    required this.description,
  });

  final List<String> highlights;
  final String description;

  String get summary => description.trim();
}

class OpenAIImageService {
  static const String _localApiKey = 'sk-t4m3myEEkA3QlV1650Ad39Bd9888468dBaF689D4D2B72d72';

  OpenAIImageService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.gpt.ge/v1',
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 120),
              ),
            );

  final Dio _dio;

  static String get _apiKey {
    final fromDefine =
        const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '').trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    return _localApiKey.trim();
  }

  Future<String> generateNailImage({
    File? referenceImage,
    required String outfitNotes,
    String? preferredColors,
    String? preferredStyle,
    String? preferredElements,
    String? customPrompt,
    String size = '1024x1024',
  }) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        'Missing OPENAI_API_KEY. Fill OpenAIImageService._localApiKey or set --dart-define=OPENAI_API_KEY=YOUR_KEY',
      );
    }

    final prompt = _buildPrompt(
      hasReferenceImage: referenceImage != null,
      outfitNotes: outfitNotes,
      preferredColors: preferredColors,
      preferredStyle: preferredStyle,
      preferredElements: preferredElements,
      customPrompt: customPrompt,
    );

    if (referenceImage != null) {
      final fileName = referenceImage.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'model': 'flux-kontext-pro',
        'prompt': prompt,
        'n': '1',
        'size': size,
        'response_format': 'url',
        'image': await MultipartFile.fromFile(
          referenceImage.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/images/edits',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      final url = _extractImageUrl(response.data);
      final bytes = await _downloadBytes(url);
      return _writeTempImage(bytes, url: url);
    }

    final response = await _dio.post(
      '/images/generations',
      data: {
        'model': 'flux-kontext-pro',
        'prompt': prompt,
        'n': 1,
        'size': size,
        'response_format': 'url',
      },
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );

    final url = _extractImageUrl(response.data);
    final bytes = await _downloadBytes(url);
    return _writeTempImage(bytes, url: url);
  }

  String _buildPrompt({
    required bool hasReferenceImage,
    required String outfitNotes,
    String? preferredColors,
    String? preferredStyle,
    String? preferredElements,
    String? customPrompt,
  }) {
    final notes = outfitNotes.trim();
    final colors = (preferredColors ?? '').trim();
    final style = (preferredStyle ?? '').trim();
    final elements = (preferredElements ?? '').trim();
    final extra = (customPrompt ?? '').trim();

    final hasAnyUserRequest =
        notes.isNotEmpty ||
        colors.isNotEmpty ||
        style.isNotEmpty ||
        elements.isNotEmpty ||
        extra.isNotEmpty;

    final lines = <String>[
      if (hasReferenceImage)
        'Use the provided outfit photo as style reference only.'
      else if (notes.isNotEmpty)
        'Use the user outfit description as style reference (infer season, occasion, accessories, and mood).'
      else if (hasAnyUserRequest)
        'No outfit photo/notes provided. Assume a neutral everyday outfit; focus on the user preferences.',
      'Always generate the final nail image. Never ask the user for more information. Never output apologies.',
      'Recommend a manicure design that matches the outfit vibe: colors, textures/materials, mood, season, accessories.',
      'Important: do NOT output the outfit photo; output a clean studio image of a hand with the nail design on a neutral background.',
      'Photorealistic, high quality, soft lighting.',
      'No text, no letters, no captions, no logos, no watermark, no UI elements.',
      'Make the manicure cohesive and wearable, with tasteful details.',
      if (notes.isNotEmpty) 'Outfit notes: $notes.',
      if (colors.isNotEmpty) 'Preferred colors: $colors.',
      if (style.isNotEmpty) 'Preferred style: $style.',
      if (elements.isNotEmpty) 'Preferred elements: $elements.',
      if (extra.isNotEmpty) 'Extra request: $extra.',
      'If any preference conflicts with the outfit, prioritize the outfit match but keep the preference as inspiration.',
    ];

    return lines.join(' ');
  }

  Future<NailCopyResult> generateNailCopy({
    required String outfitNotes,
    String? preferredColors,
    String? preferredStyle,
    String? preferredElements,
    String? customPrompt,
  }) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty) {
      throw StateError(
        'Missing OPENAI_API_KEY. Fill OpenAIImageService._localApiKey or set --dart-define=OPENAI_API_KEY=YOUR_KEY',
      );
    }

    final notes = outfitNotes.trim();
    final colors = (preferredColors ?? '').trim();
    final style = (preferredStyle ?? '').trim();
    final elements = (preferredElements ?? '').trim();
    final extra = (customPrompt ?? '').trim();

    final userLines = <String>[
      if (notes.isNotEmpty) 'Outfit notes: $notes',
      if (colors.isNotEmpty) 'Preferred colors: $colors',
      if (style.isNotEmpty) 'Preferred style: $style',
      if (elements.isNotEmpty) 'Preferred elements: $elements',
      if (extra.isNotEmpty) 'Extra request: $extra',
      if (notes.isEmpty &&
          colors.isEmpty &&
          style.isEmpty &&
          elements.isEmpty &&
          extra.isEmpty)
        'No extra constraints; recommend something versatile and flattering.',
    ];

    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': 'gpt-4o-mini',
        'temperature': 0.7,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a manicure stylist. Return STRICT JSON only. No markdown, no code fences, no extra text. Output language must be English only.',
          },
          {
            'role': 'user',
            'content': [
              'Based on today outfit vibe, recommend a nail design.',
              'Return JSON with this schema:',
              '{ "highlights": ["keyword1","keyword2","keyword3"], "description": "1 short paragraph" }',
              'Rules:',
              '- highlights: 3-6 short keywords/phrases.',
              '- description: 1 paragraph, 2-4 sentences, concise.',
              '- Output English only in both fields.',
              '- Never use Chinese or any other non-English language.',
              'User info:',
              ...userLines,
            ].join('\n'),
          },
        ],
      },
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected response format.');
    }
    final choices = data['choices'];
    if (choices is! List || choices.isEmpty) {
      throw StateError('No choices returned.');
    }
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('Unexpected choice payload.');
    }
    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw StateError('Unexpected message payload.');
    }
    final content = message['content'];
    if (content is! String || content.trim().isEmpty) {
      throw StateError('Empty content.');
    }
    final trimmed = content.trim();
    final dynamic parsed = jsonDecode(trimmed);
    if (parsed is! Map<String, dynamic>) {
      throw StateError('Unexpected JSON payload.');
    }
    final rawHighlights = parsed['highlights'];
    final rawDescription = parsed['description'];

    final highlights = <String>[];
    if (rawHighlights is List) {
      for (final v in rawHighlights) {
        final s = '$v'.trim();
        if (s.isNotEmpty) highlights.add(s);
      }
    }
    final description = (rawDescription is String) ? rawDescription.trim() : '';
    if (highlights.isEmpty && description.isEmpty) {
      throw StateError('Empty JSON fields.');
    }
    return NailCopyResult(
      highlights: highlights.take(6).toList(),
      description: description,
    );
  }

  String _extractImageUrl(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected response format.');
    }
    final list = data['data'];
    if (list is! List || list.isEmpty) {
      throw StateError('No image data returned.');
    }
    final first = list.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('Unexpected image payload.');
    }
    final url = first['url'];
    if (url is! String || url.trim().isEmpty) {
      throw StateError('Missing url in response.');
    }
    return url.trim();
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final resp = await _dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = resp.data;
    if (bytes == null || bytes.isEmpty) {
      throw StateError('Empty image download.');
    }
    return Uint8List.fromList(bytes);
  }

  Future<String> _writeTempImage(Uint8List bytes, {required String url}) async {
    final dir = await Directory.systemTemp.createTemp('rova_nails_');
    final lower = url.toLowerCase();
    final ext = lower.contains('.jpg') || lower.contains('.jpeg')
        ? 'jpg'
        : (lower.contains('.webp') ? 'webp' : 'png');
    final file = File(
      '${dir.path}${Platform.pathSeparator}nail_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
