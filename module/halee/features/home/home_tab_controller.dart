import 'package:flutter/foundation.dart';

class HomeTabController {
  HomeTabController._();

  /// 0 = Explore, 1 = ganerate (disabled), 2 = Profile
  static final ValueNotifier<int> index = ValueNotifier<int>(0);
}
