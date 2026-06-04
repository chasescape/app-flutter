import 'package:flutter/foundation.dart';
import '../../models/novel.dart';
import '../../services/coins_manager.dart';
import '../../services/storage_service.dart';

/// App State - Managed by InheritedNotifier
/// Contains all application state including novels, coins, and achievements
class AppState extends ChangeNotifier {
  static const int recordCost = 50;

  // Novel Records
  List<Novel> _novels = [];
  List<Novel> get novels => List.unmodifiable(_novels);

  // Coins Manager instance
  final CoinsManager _coinsManager = CoinsManager.instance;

  // Coin Balance (delegated to CoinsManager)
  int get coinBalance => _coinsManager.coins;

  // Free Usage Count
  int _freeCount = 0;
  int get freeCount => _freeCount;

  // Reading Stats
  ReadingStats? _readingStats;
  ReadingStats? get readingStats => _readingStats;

  // Achievements
  List<Achievement> _achievements = [];
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  // Loading State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error State
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AppState() {
    _initializeState();
  }

  // Initialize state from local storage
  Future<void> _initializeState() async {
    // Initialize Coins Manager
    await _coinsManager.initialize();

    // Load free count
    _freeCount = await StorageService.loadFreeCount();

    // Load novels
    _novels = await StorageService.loadNovels();

    // Initialize achievements
    _initializeAchievements();
    notifyListeners();
  }

  // Initialize achievements
  void _initializeAchievements() {
    _achievements = [
      Achievement(
        id: 'first_novel',
        title: 'First Novel',
        description: 'Record your first novel',
        icon: '📖',
        isUnlocked: false,
      ),
      Achievement(
        id: '10_books',
        title: 'Bookworm',
        description: 'Finish 10 novels',
        icon: '🐛',
        isUnlocked: false,
      ),
      Achievement(
        id: 'weekend_reader',
        title: 'Weekend Reader',
        description: 'Read on 3 consecutive weekends',
        icon: '☕',
        isUnlocked: false,
      ),
      Achievement(
        id: 'genre_explorer',
        title: 'Genre Explorer',
        description: 'Read novels from 5 different genres',
        icon: '🗺️',
        isUnlocked: false,
      ),
      Achievement(
        id: 'marathon_reader',
        title: 'Marathon Reader',
        description: 'Read for 10+ hours in total',
        icon: '🏃',
        isUnlocked: false,
      ),
      Achievement(
        id: 'dedicated_fan',
        title: 'Dedicated Fan',
        description: 'Record 50 novels',
        icon: '⭐',
        isUnlocked: false,
      ),
    ];
  }

  // Novel Operations
  void addNovel(Novel novel) {
    _novels.insert(0, novel);
    StorageService.saveNovels(_novels);
    _updateReadingStats();
    _checkAchievements();
    notifyListeners();
  }

  void updateNovel(Novel updatedNovel) {
    final index = _novels.indexWhere((n) => n.id == updatedNovel.id);
    if (index != -1) {
      _novels[index] = updatedNovel;
      StorageService.saveNovels(_novels);
      _updateReadingStats();
      _checkAchievements();
      notifyListeners();
    }
  }

  void deleteNovel(String novelId) {
    _novels.removeWhere((n) => n.id == novelId);
    StorageService.saveNovels(_novels);
    _updateReadingStats();
    notifyListeners();
  }

  Novel? getNovelById(String id) {
    try {
      return _novels.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Novel> getNovelsByStatus(NovelStatus status) {
    return _novels.where((n) => n.status == status).toList();
  }

  List<Novel> searchNovels(String query) {
    final lowerQuery = query.toLowerCase();
    return _novels.where((n) {
      return n.title.toLowerCase().contains(lowerQuery) ||
          n.author.toLowerCase().contains(lowerQuery) ||
          n.characters.any((c) => c.name.toLowerCase().contains(lowerQuery)) ||
          (n.plotSummary?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Reading Stats
  void _updateReadingStats() {
    final finished = _novels.where((n) => n.isFinished).length;
    final reading = _novels.where((n) => n.isReading).length;
    final totalMinutes =
        _novels.fold<int>(0, (sum, n) => sum + (n.readingMinutes ?? 0));

    final now = DateTime.now();
    final currentMonth = finishedBooksInMonth(now.month, now.year);
    final currentYear = finishedBooksInYear(now.year);

    // Generate monthly data for the last 6 months
    final monthlyData = <MonthlyData>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthName = _getMonthName(month.month);
      final count = finishedBooksInMonth(month.month, month.year);
      final minutes = readingMinutesInMonth(month.month, month.year);
      monthlyData.add(MonthlyData(
        month: monthName,
        booksRead: count,
        minutesRead: minutes,
      ));
    }

    _readingStats = ReadingStats(
      totalBooks: _novels.length,
      finishedBooks: finished,
      readingBooks: reading,
      totalReadingMinutes: totalMinutes,
      currentMonthBooks: currentMonth,
      currentYearBooks: currentYear,
      monthlyData: monthlyData,
    );
  }

  int finishedBooksInMonth(int month, int year) {
    return _novels
        .where((n) =>
            n.isFinished &&
            n.finishDate != null &&
            n.finishDate!.month == month &&
            n.finishDate!.year == year)
        .length;
  }

  int finishedBooksInYear(int year) {
    return _novels
        .where((n) =>
            n.isFinished && n.finishDate != null && n.finishDate!.year == year)
        .length;
  }

  int readingMinutesInMonth(int month, int year) {
    return _novels.fold<int>(0, (sum, n) {
      if (n.finishDate != null &&
          n.finishDate!.month == month &&
          n.finishDate!.year == year) {
        return sum + (n.readingMinutes ?? 0);
      }
      return sum;
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Achievement Checking
  void _checkAchievements() {
    for (var i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      if (!achievement.isUnlocked) {
        bool unlocked = false;

        switch (achievement.id) {
          case 'first_novel':
            unlocked = _novels.isNotEmpty;
            break;
          case '10_books':
            unlocked = (_readingStats?.finishedBooks ?? 0) >= 10;
            break;
          case 'genre_explorer':
            final genres = _novels.map((n) => n.genre).toSet();
            unlocked = genres.length >= 5;
            break;
          case 'marathon_reader':
            unlocked = (_readingStats?.totalReadingMinutes ?? 0) >= 600;
            break;
          case 'dedicated_fan':
            unlocked = _novels.length >= 50;
            break;
        }

        if (unlocked) {
          _achievements[i] = Achievement(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            icon: achievement.icon,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
        }
      }
    }
  }

  // Coin Operations (delegated to CoinsManager)
  bool canCreateRecord() {
    return _freeCount > 0 || _coinsManager.isEnough(recordCost);
  }

  int getRecordCost() {
    if (_freeCount > 0) return 0;
    return recordCost;
  }

  void consumeCoinsForRecord() {
    if (_freeCount > 0) {
      _freeCount--;
      StorageService.saveFreeCount(_freeCount);
    } else {
      final cost = getRecordCost();
      _coinsManager.subCoins(cost);
    }
    notifyListeners();
  }

  void addCoins(int amount) {
    _coinsManager.addCoins(amount);
    // No need to call notifyListeners() as CoinsManager already notifies
  }

  Future<void> clearAllData() async {
    _novels = [];
    _freeCount = 0;
    _readingStats = null;
    _errorMessage = null;
    _isLoading = false;
    _initializeAchievements();

    await StorageService.clearAll();
    await _coinsManager.clear();
    await StorageService.saveFreeCount(0);
    notifyListeners();
  }

  // Loading State
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error State
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get recent novels (last 5)
  List<Novel> getRecentNovels() {
    return _novels.take(5).toList();
  }

  // Get novels by genre
  Map<NovelGenre, List<Novel>> getNovelsByGenre() {
    final Map<NovelGenre, List<Novel>> grouped = {};
    for (final novel in _novels) {
      grouped.putIfAbsent(novel.genre, () => []);
      grouped[novel.genre]!.add(novel);
    }
    return grouped;
  }

  // Get novels grouped by status
  Map<NovelStatus, List<Novel>> getNovelsByStatusGrouped() {
    final Map<NovelStatus, List<Novel>> grouped = {};
    for (final novel in _novels) {
      grouped.putIfAbsent(novel.status, () => []);
      grouped[novel.status]!.add(novel);
    }
    return grouped;
  }
}
