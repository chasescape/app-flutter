class AppConstants {
  AppConstants._();

  static const String appName = 'ComposePilot';
  static const String version = '1.0.0';

  static const int minFreeCredits = 1;
  static const int maxFreeCredits = 3;
  static const int minCostPerAnalysis = 50;
  static const int maxCostPerAnalysis = 100;

  static const int maxHistoryItems = 50;

  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
}
