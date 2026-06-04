import 'package:flutter/material.dart';

/// Route State Manager - Manages page stack state
class RouterStateManager extends ChangeNotifier {
  List<Page> _pages = [];

  RouterStateManager(Page defaultPage) {
    _pages = [defaultPage];
  }

  /// Get current page stack (immutable list)
  List<Page> get pages => List.unmodifiable(_pages);

  /// Add page to stack top
  void push(Page page) {
    _pages = [..._pages, page];
    notifyListeners();
  }

  /// Clear stack and jump to specified page
  void to(Page page) {
    _pages = [page];
    notifyListeners();
  }

  /// Replace current page
  void replace(Page page) {
    if (_pages.isNotEmpty) {
      _pages = [..._pages.sublist(0, _pages.length - 1), page];
    } else {
      _pages = [page];
    }
    notifyListeners();
  }

  /// Go back to previous page
  void goBack() {
    if (_pages.length > 1) {
      _pages = List.from(_pages)..removeLast();
      notifyListeners();
    }
  }

  /// Go back to home page (clear stack to only home)
  void popToHome() {
    if (_pages.isNotEmpty) {
      _pages = [_pages.first];
      notifyListeners();
    }
  }

  /// Get current page (top of stack)
  Page get currentPage => _pages.last;

  /// Get current route name (extracted from key)
  String get currentRouteName {
    final key = currentPage.key;
    if (key is ValueKey) {
      final value = key.value;
      if (value is String) {
        return value.split('_').first;
      }
    }
    return 'unknown';
  }

  /// Get page stack depth
  int get stackDepth => _pages.length;

  /// Check if is root page
  bool get isRootPage => _pages.length == 1;
}
