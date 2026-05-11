import 'package:flutter/foundation.dart';

/// Creation Model - Daily Happiness App
class CreationModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String? resultText;
  final String? aiAnalysis;
  final int costCoins;
  final DateTime createdAt;

  CreationModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.resultText,
    this.aiAnalysis,
    this.costCoins = 0,
    required this.createdAt,
  });

  CreationModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? resultText,
    String? aiAnalysis,
    int? costCoins,
    DateTime? createdAt,
  }) {
    return CreationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      resultText: resultText ?? this.resultText,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      costCoins: costCoins ?? this.costCoins,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'resultText': resultText,
      'aiAnalysis': aiAnalysis,
      'costCoins': costCoins,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CreationModel.fromJson(Map<String, dynamic> json) {
    return CreationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      resultText: json['resultText'] as String?,
      aiAnalysis: json['aiAnalysis'] as String?,
      costCoins: json['costCoins'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Creations State - Manages user creations
class CreationsState extends ChangeNotifier {
  final List<CreationModel> _creations = [];
  bool _isLoading = false;
  int _currentStep = 1;

  List<CreationModel> get creations => _creations;
  bool get isLoading => _isLoading;
  int get currentStep => _currentStep;

  void setCreations(List<CreationModel> creations) {
    _creations.clear();
    _creations.addAll(creations);
    notifyListeners();
  }

  void addCreation(CreationModel creation) {
    _creations.insert(0, creation);
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void clearCreations() {
    _creations.clear();
    notifyListeners();
  }

  static final CreationsState _instance = CreationsState._internal();
  CreationsState._internal();
  factory CreationsState() => _instance;
}
