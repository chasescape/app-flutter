import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData9 = SnapAnalysis(
  assetImg: A.assets_halee_9,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'Large purple lily flower being photographed in a natural setting'),
    scene: SceneDimension(value: 'Nature', confidence: 0.98, evidence: 'Dirt ground, green grass, and blurred trees in the background'),
    lighting: SceneDimension(value: 'Natural Soft', confidence: 0.9, evidence: 'Diffused daylight with gentle shadows and even illumination'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.85, evidence: 'The flower and the photographer\'s face are centrally located'),
    colorTone: SceneDimension(value: 'Neutral', confidence: 0.8, evidence: 'Realistic green, brown, and deep purple tones without heavy filtering'),
    atmosphere: SceneDimension(value: 'Fresh', confidence: 0.85, evidence: 'Focus on outdoor growth and the quiet act of creation'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a fantastic \'behind-the-scenes\' shot that captures the focus and beauty of nature photography perfectly.',
    strengths: ['Excellent shallow depth of field that separates the subject from the background', 'Engaging low-angle perspective that puts the viewer at ground level', 'Rich, vibrant colors in the flower that draw the eye immediately'],
    topImprovement: 'Try shifting your position slightly to the side to keep the flower from completely obscuring the photographer\'s face.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Reveal the eyes',
      action: 'Move your camera about six inches to the left while staying at the same height.',
      expectedResult: 'This will show the photographer\'s eye looking through the viewfinder, creating a more personal connection.',
    ),
    ImprovementTip(
      category: 'Framing',
      title: 'Use the foliage',
      action: 'Crouch even lower so the green leaves at the bottom of the plant slightly overlap the bottom of your frame.',
      expectedResult: 'Creates a natural \'foreground blur\' that adds more depth and layers to the image.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Chase the rim light',
      action: 'Wait for the sun to be lower in the sky (closer to sunset) and position yourself so the light comes from behind the flower.',
      expectedResult: 'Will create a beautiful \'halo\' effect on the petals and the photographer\'s hair.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Macro',
      description: 'An extreme close-up focusing only on the yellow stamen and the texture of the purple petals.',
      executionTip: 'Get as close as your lens allows and focus manually on the very center of the flower.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide 16:9 crop with a slightly moodier, cooler color grade.',
      executionTip: 'Crop the top and bottom of the image and slightly increase the blue tones in the shadows.',
    ),
    CreativeVariant(
      style: 'Documentary',
      description: 'A wider shot that includes more of the garden environment to show the scale of the scene.',
      executionTip: 'Step back five feet to show the photographer\'s full body and the surrounding trees.',
    ),
  ],
  funFact: 'Getting down to the same level as your subject—whether it\'s a flower or a pet—is one of the fastest ways to make a photo feel professional and immersive.',
  shareCaption: 'Finding the perfect angle for nature\'s masterpieces. 🌸✨',
  tags: ['naturephotography', 'behindthelens', 'flowerpower', 'bokeh', 'creativeprocess', 'lowangle', 'gardenlife'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'A person\'s face is visible in the frame.',
  ),
);
