import '../core/mixin/singleton_mixin.dart';

class AIService with SingletonMixin<AIService> {
  AIService._();

  static AIService get instance =>
      SingletonMixin.getInstance(() => AIService._());

  Future<String> generateMotivationalQuote(String context) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final quotes = [
      "Every morning brings new potential, but if you dwell on the misfortunes of the day before, you tend to overlook tremendous opportunities.",
      "The way to get started is to quit talking and begin doing.",
      "Don't watch the clock; do what it does. Keep going.",
      "You don't have to be great to start, but you have to start to be great.",
      "The secret of your future is hidden in your daily routine.",
      "Morning is an important time of day, because how you spend your morning can often tell you what kind of day you are going to have.",
      "Each morning we are born again. What we do today is what matters most.",
      "The sun is a daily reminder that we too can rise again from the darkness, that we too can shine our own light.",
      "Every morning you have two choices: continue to sleep with your dreams, or wake up and chase them.",
      "Your talent determines what you can do. Your motivation determines how much you are willing to do. Your attitude determines how well you do it.",
    ];

    return quotes[(DateTime.now().millisecondsSinceEpoch + context.length) % quotes.length];
  }

  Future<String> getBedtimeReminder() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final reminders = [
      "Time to wind down! A good night's sleep sets you up for success tomorrow.",
      "Early to bed and early to rise, makes a man healthy, wealthy, and wise.",
      "Your body needs rest to perform at its best tomorrow. Sleep well!",
      "Rest tonight so you can rise and shine tomorrow!",
      "Quality sleep leads to productive mornings. Sweet dreams!",
    ];

    return reminders[DateTime.now().millisecond % reminders.length];
  }

  Future<Map<String, dynamic>> analyzeSleepPattern(List<Map<String, dynamic>> sleepData) async {
    await Future.delayed(const Duration(seconds: 1));

    if (sleepData.isEmpty) {
      return {
        'averageSleepTime': '7h 30m',
        'consistency': 75,
        'recommendation': 'Try to maintain a consistent sleep schedule.',
      };
    }

    return {
      'averageSleepTime': '7h 15m',
      'consistency': 68,
      'recommendation': 'Your sleep pattern varies. Consider setting a consistent bedtime.',
    };
  }
}
