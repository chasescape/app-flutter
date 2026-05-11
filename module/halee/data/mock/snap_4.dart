import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData4 = SnapAnalysis(
  assetImg: A.assets_halee_4,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Portrait', confidence: 0.98, evidence: 'Young child running with arms outstretched'),
    scene: SceneDimension(value: 'Nature', confidence: 0.99, evidence: 'Expansive field of sunflowers under an open sky'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.99, evidence: 'Low, warm sun on the horizon creating backlighting'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.92, evidence: 'Subject is positioned in the center of the dirt path'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.99, evidence: 'Dominant yellow, orange, and golden hues'),
    atmosphere: SceneDimension(value: 'Playful', confidence: 0.96, evidence: 'Subject\'s joyful expression and energetic running pose'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'A beautiful, high-energy shot that perfectly captures the magic of childhood during the best light of the day.',
    strengths: ['Excellent use of backlighting to create a glowing \'halo\' effect around the hair', 'Perfectly timed candid expression of joy', 'Strong sense of depth created by the rows of sunflowers'],
    topImprovement: 'Try lowering your camera height to eye-level with the sunflowers to make the field feel more immersive.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Crouch for impact',
      action: 'Physically lower your camera so it is level with the sunflower heads or the child\'s waist.',
      expectedResult: 'This makes the sunflowers look taller and more dominant, creating a more intimate \'secret garden\' feel.',
    ),
    ImprovementTip(
      category: 'Composition',
      title: 'Apply the Rule of Thirds',
      action: 'Position the running child on either the left or right vertical third of the frame rather than the center.',
      expectedResult: 'Gives the subject \'room to run\' into the frame, making the composition feel more dynamic and less static.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Block the direct sun',
      action: 'Slightly adjust your position so the sun is partially hidden behind a sunflower head or the child\'s shoulder.',
      expectedResult: 'Reduces the hazy lens flare and increases contrast while maintaining the beautiful golden rim light.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Silhouette',
      description: 'A dark, sharp outline of the child jumping against the vibrant orange sky.',
      executionTip: 'Expose your camera settings for the brightest part of the sky and ensure the subject is directly in front of the light source.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-angle, landscape-oriented view that emphasizes the vastness of the field.',
      executionTip: 'Turn your phone horizontally and use a wide-angle lens if available to capture more of the horizon line.',
    ),
    CreativeVariant(
      style: 'Macro',
      description: 'A tight, detailed shot of a single sunflower with the child blurred in the background.',
      executionTip: 'Move very close to a foreground sunflower and tap it on your screen to focus, letting the background fall into a soft blur.',
    ),
  ],
  funFact: 'Sunflowers are famous for heliotropism—young flowers actually track the sun across the sky from east to west throughout the day!',
  shareCaption: 'Chasing sunsets and golden dreams in a sea of sunflowers. 🌻✨',
  tags: ['#sunflowerfield', '#goldenhour', '#childhoodunplugged', '#naturallight', '#portraitphotography', '#sunsetlovers', '#nextsnap'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'Image contains a clear view of a child\'s face. Ensure you have parental permission before sharing on public social media.',
  ),
);
