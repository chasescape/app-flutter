class SceneAiConfig {
  SceneAiConfig._();

  static const String baseUrl = 'https://api.gpt.ge';

  // Replace this with your real API key for direct client-side AI calls.
  static const String defaultApiKey = 'sk-Oz3Mv9kShkkS97Lx3eC690Cf4d4a49018c311199C6252c2a';

  static const String model = 'gpt-4o-2024-05-13';
  static const int maxTokens = 1500;
  static const double temperature = 0.7;
  static const int timeoutSeconds = 60;
}
