import 'package:flutter/material.dart';
import 'dart:math';

/// GUID Generator
/// Generates unique IDs for novels, characters, etc.
class GuidUtils {
  GuidUtils._();

  static String generate() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List.generate(16, (i) => random.nextInt(256));

    final hex = randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // Format: XXXXXXXX-XXXX-4XXX-YXXX-XXXXXXXXXXXX
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      '4${hex.substring(13, 16)}', // Version 4
      '${(int.parse(hex[16], radix: 16) & 0x3 | 0x8).toRadixString(16)}${hex.substring(17, 20)}', // Variant
      hex.substring(20, 32),
    ].join('-');
  }

  static String generateShort() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$timestamp-$random';
  }
}
