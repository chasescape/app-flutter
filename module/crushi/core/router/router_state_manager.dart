import 'package:flutter/material.dart';

class RouterStateManager extends ChangeNotifier {
  List<Page> _pages = [];

  RouterStateManager(Page defaultPage) {
    _pages = [defaultPage];
  }

  List<Page> get pages => List.unmodifiable(_pages);

  Page get currentPage => _pages.last;

  bool get isRootPage => _pages.length == 1;

  void push(Page page) {
    _pages = [..._pages, page];
    notifyListeners();
  }

  void to(Page page) {
    _pages = [page];
    notifyListeners();
  }

  void goBack() {
    if (_pages.length > 1) {
      _pages = List.from(_pages)..removeLast();
      notifyListeners();
    }
  }

  void popToHome() {
    if (_pages.isNotEmpty) {
      _pages = [_pages.first];
      notifyListeners();
    }
  }
}
