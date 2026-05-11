// SparkFlow 灵感结果 Mock 数据聚合文件
// Auto-generated from image_to_text_output/*.txt
// DO NOT EDIT manually

library spark_mock_data;

import 'sparkData_1.dart';
import 'sparkData_2.dart';
import 'sparkData_3.dart';
import 'sparkData_4.dart';
import 'sparkData_5.dart';
import 'sparkData_6.dart';
import 'sparkData_7.dart';
import 'sparkData_8.dart';
import 'sparkData_9.dart';
import 'sparkData_10.dart';
import 'sparkData_11.dart';
import 'sparkData_12.dart';
import 'sparkData_13.dart';
import 'sparkData_14.dart';
import 'sparkData_15.dart';
import 'sparkData_16.dart';
import 'sparkData_17.dart';
import 'sparkData_18.dart';
import 'sparkData_19.dart';
import 'sparkData_20.dart';

import '../models/spark_result.dart';

/// 所有 Mock 数据聚合列表
/// 按文件编号顺序排列
final List<SparkResult> allSparkMockData = [
  sparkData1,
  sparkData2,
  sparkData3,
  sparkData4,
  sparkData5,
  sparkData6,
  sparkData7,
  sparkData8,
  sparkData9,
  sparkData10,
  sparkData11,
  sparkData12,
  sparkData13,
  sparkData14,
  sparkData15,
  sparkData16,
  sparkData17,
  sparkData18,
  sparkData19,
  sparkData20,
];

/// 根据 assetImg 获取对应的 Mock 数据
SparkResult? getSparkDataByAsset(String assetImg) {
  for (final data in allSparkMockData) {
    if (data.assetImg == assetImg) {
      return data;
    }
  }
  return null;
}

/// 获取随机 Mock 数据
SparkResult getRandomSparkData() {
  return allSparkMockData[
      (DateTime.now().millisecondsSinceEpoch) % allSparkMockData.length];
}
