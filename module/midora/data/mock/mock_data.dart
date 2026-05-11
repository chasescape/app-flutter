// Auto-generated aggregate file
// Export all scene data and provide unified access

import '../models/scene_card.dart';

import 'scene_data_1.dart';
import 'scene_data_2.dart';
import 'scene_data_3.dart';
import 'scene_data_4.dart';
import 'scene_data_5.dart';
import 'scene_data_6.dart';
import 'scene_data_7.dart';
import 'scene_data_8.dart';
import 'scene_data_9.dart';
import 'scene_data_10.dart';
import 'scene_data_11.dart';
import 'scene_data_12.dart';
import 'scene_data_13.dart';
import 'scene_data_14.dart';
import 'scene_data_15.dart';
import 'scene_data_16.dart';
import 'scene_data_17.dart';
import 'scene_data_18.dart';
import 'scene_data_19.dart';
import 'scene_data_20.dart';

/// All mock scene card data
final List<SceneCard> allSceneData = [
  sceneData1,
  sceneData2,
  sceneData3,
  sceneData4,
  sceneData5,
  sceneData6,
  sceneData7,
  sceneData8,
  sceneData9,
  sceneData10,
  sceneData11,
  sceneData12,
  sceneData13,
  sceneData14,
  sceneData15,
  sceneData16,
  sceneData17,
  sceneData18,
  sceneData19,
  sceneData20,
];

/// Get scene data by index (1-based)
SceneCard? getSceneData(int index) {
  if (index < 1 || index > allSceneData.length) return null;
  return allSceneData[index - 1];
}