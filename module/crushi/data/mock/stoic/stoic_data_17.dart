import '../../../../gen_a/A.dart';
import '../../models/stoic_card.dart';

final stoic_data_17 = StoicCard(
  assetImg: A.assets_crushi_17,
  sceneCard: const SceneCard(
    setting: TaggedField(value: 'Kitchen', confidence: 1.0,
      detail: 'cutting board, fresh vegetables, stove, and kitchen utensils visible',
    ),
    timeOfDay: TaggedField(value: 'Morning', confidence: 0.8,
      detail: 'bright, soft natural light streaming through a window suggesting early preparation',
    ),
    visualMood: TaggedField(value: 'Serene', confidence: 0.9,
      detail: 'focused, rhythmic activity of food preparation in a clean environment',
    ),
    stoicVirtue: TaggedField(value: 'Temperance', confidence: 0.9,
      detail: 'the deliberate, measured action of preparing sustenance reflects self-control and intentional living',
    ),
    humanPresence: TaggedField(value: 'Alone', confidence: 0.9,
      detail: 'only hands visible performing a solitary task',
    ),
    natureRatio: TaggedField(value: 'Balanced', confidence: 0.8,
      detail: 'fresh produce contrasted with man-made kitchen tools',
    ),
    keyObjects: ["Chef's knife", "Wooden cutting board", "Fresh tomatoes", "Bell pepper", "Cooking pot"],
    dominantColors: ["Red", "Warm wood tones", "Green"],
    lightQuality: 'Soft diffused natural morning light',
  ),
  oneLineCapture: 'In the rhythmic repetition of a simple task, we find the quiet order of a disciplined life.',
  tags: const ["Focus", "Routine", "Presence", "Simplicity", "Sustenance"],
  safety: const SafetyInfo(hasSensitiveContent: false
  ),
);
