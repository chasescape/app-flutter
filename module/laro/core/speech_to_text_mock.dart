/// Mock implementation of speech_to_text package for compilation purposes
/// This is a temporary workaround when the package cannot be downloaded

class SpeechToText {
  bool _hasSpeech = false;

  Future<bool> initialize({
    void Function(String)? onStatus,
    void Function(dynamic)? onError,
  }) async {
    _hasSpeech = true;
    return true;
  }

  Future<void> listen({
    void Function(SpeechRecognitionResult)? onResult,
    void Function(String)? onSoundLevelChange,
    String? localeId,
    int? listenMode,
    Duration? listenFor,
    Duration? pauseFor,
    bool? partialResults,
  }) async {}

  Future<void> stop() async {}

  Future<void> cancel() async {}

  bool get isAvailable => _hasSpeech;
  bool get isListening => false;
}

class SpeechRecognitionResult {
  final String recognizedWords;
  final bool finalResult;

  SpeechRecognitionResult({
    required this.recognizedWords,
    required this.finalResult,
  });
}

class SpeechRecognitionError {
  final String errorMsg;

  SpeechRecognitionError(this.errorMsg);
}
