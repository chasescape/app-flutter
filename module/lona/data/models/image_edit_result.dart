class ImageEditResult {
  final String id;
  final List<String> oldImagePaths;
  final String resultImagePath;
  final String title;
  final String subtitle;
  final String whyBetter;
  final String howItWorks;
  final String editInstructionContext;
  final DateTime createdAt;
  final int coinsUsed;

  ImageEditResult({
    required this.id,
    required this.oldImagePaths,
    required this.resultImagePath,
    required this.title,
    required this.subtitle,
    required this.whyBetter,
    required this.howItWorks,
    required this.editInstructionContext,
    required this.createdAt,
    required this.coinsUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'oldImagePaths': oldImagePaths,
      'resultImagePath': resultImagePath,
      'title': title,
      'subtitle': subtitle,
      'whyBetter': whyBetter,
      'howItWorks': howItWorks,
      'editInstructionContext': editInstructionContext,
      'createdAt': createdAt.toIso8601String(),
      'coinsUsed': coinsUsed,
    };
  }

  factory ImageEditResult.fromJson(Map<String, dynamic> json) {
    return ImageEditResult(
      id: json['id'] as String,
      oldImagePaths: List<String>.from(json['oldImagePaths'] as List),
      resultImagePath: json['resultImagePath'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      whyBetter: json['whyBetter'] as String,
      howItWorks: json['howItWorks'] as String,
      editInstructionContext: json['editInstructionContext'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      coinsUsed: json['coinsUsed'] as int,
    );
  }

  @override
  String toString() {
    return 'ImageEditResult(id:$id, title:$title, oldImages:${oldImagePaths.length}, result:$resultImagePath)';
  }
}
