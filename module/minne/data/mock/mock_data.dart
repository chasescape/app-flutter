// Auto-generated aggregate file for CherishCard mock data
// DO NOT EDIT MANUALLY

import '../models/cherish_card.dart';
import 'cherish_data_1.dart';
import 'cherish_data_2.dart';
import 'cherish_data_3.dart';
import 'cherish_data_4.dart';
import 'cherish_data_5.dart';
import 'cherish_data_6.dart';
import 'cherish_data_7.dart';
import 'cherish_data_8.dart';
import 'cherish_data_9.dart';
import 'cherish_data_10.dart';
import 'cherish_data_11.dart';
import 'cherish_data_12.dart';
import 'cherish_data_13.dart';
import 'cherish_data_14.dart';
import 'cherish_data_15.dart';
import 'cherish_data_16.dart';
import 'cherish_data_17.dart';
import 'cherish_data_18.dart';
import 'cherish_data_19.dart';
import 'cherish_data_20.dart';

/// 所有 CherishCard 模拟数据的聚合列表
final List<CherishCard> allCherishData = [
  cherishData1,
  cherishData2,
  cherishData3,
  cherishData4,
  cherishData5,
  cherishData6,
  cherishData7,
  cherishData8,
  cherishData9,
  cherishData10,
  cherishData11,
  cherishData12,
  cherishData13,
  cherishData14,
  cherishData15,
  cherishData16,
  cherishData17,
  cherishData18,
  cherishData19,
  cherishData20,
];

/// 根据索引获取 cherish data（带越界检查）
CherishCard getCherishData(int index) {
  if (index < 0 || index >= allCherishData.length) {
    return allCherishData.first;
  }
  return allCherishData[index];
}

/// 获取随机 cherish data
CherishCard getRandomCherishData() {
  return allCherishData[(DateTime.now().millisecondsSinceEpoch) % allCherishData.length];
}
