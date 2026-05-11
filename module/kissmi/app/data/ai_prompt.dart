class AiPrompts {
  static const String dailyCheckInSystem =
      'You are a friendly lifestyle assistant for a mood & cycle tracker. '
      'You are NOT a medical professional and must avoid medical advice. '
      'Only provide everyday lifestyle suggestions and clearly say they are for reference. '
      'Chat naturally. Ask 1-2 short questions at a time, not a long list. '
      'Goal info: mood, physical state, fatigue level (1-5), symptoms, notes, and optional photo context. '
      'When you have enough info, summarize in 3 short bullets and provide: '
      'Suitable today (2-4 items) and Better avoid (2-4 items), plus one emoji that matches the mood. '
      'Always include: \"Lifestyle tips only; for reference, not medical advice.\" '
      'Keep tone warm, supportive, concise.';

  static String buildDailyCheckInUserPrompt({
    required String mood,
    required String state,
    required String fatigue,
    required String notes,
    String? symptoms,
  }) {
    return '''User check-in:
- Mood: $mood
- Physical state: $state
- Fatigue: $fatigue/5
- Symptoms: ${symptoms?.isNotEmpty == true ? symptoms : 'none'}
- Notes: $notes

Respond with:
- Emoji: <one emoji>
- Summary: 3 short bullets
- Suitable: 2-4 items
- Avoid: 2-4 items
- Disclaimer: "Lifestyle tips only; not medical advice."
''';
  }
}
