import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData7 = SnapAnalysis(
  assetImg: A.assets_halee_7,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Landscape', confidence: 0.98, evidence: 'rolling hills and distant mountains'),
    scene: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'open fields, trees, and dirt path'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.99, evidence: 'warm orange glow and long shadows from low sun'),
    composition: SceneDimension(value: 'Leading Lines', confidence: 0.92, evidence: 'winding dirt path leading the eye through the hills'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.98, evidence: 'dominant yellow, orange, and golden hues'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.9, evidence: 'peaceful sunset over a quiet landscape'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a breathtaking landscape shot that perfectly captures the magic of golden hour light and uses a winding path to create a sense of journey.',
    strengths: ['Excellent use of natural golden hour light', 'Strong foreground interest with the textured grass', 'Great sense of depth through layering'],
    topImprovement: 'Ensure maximum depth of field so that both the foreground grass and distant mountains are pin-sharp.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Camera Settings',
      title: 'Use a smaller aperture',
      action: 'Set your camera to f/11 or f/16 and use a tripod to keep the entire scene in sharp focus from front to back.',
      expectedResult: 'Produces a professional, crisp look where every detail from the grass to the horizon is clear.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your tripod',
      action: 'Physically lower your camera closer to the wildflowers in the foreground to make them feel larger and more immersive.',
      expectedResult: 'Creates a stronger \'walk-in\' effect that pulls the viewer deeper into the scene.',
    ),
    ImprovementTip(
      category: 'Timing',
      title: 'Wait for the Blue Hour',
      action: 'Stay for 20 minutes after the sun disappears to capture the soft, cool blue light as it settles over the hills.',
      expectedResult: 'Offers a completely different, more mysterious and calm mood compared to the high-energy golden glow.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A focused shot highlighting only the rhythmic, repeating curves of the hill ridges.',
      executionTip: 'Zoom in tight on the middle ground to crop out the sky and the foreground grass entirely.',
    ),
    CreativeVariant(
      style: 'Silhouette',
      description: 'A high-contrast look where the hills become dark, dramatic shapes against the glowing sky.',
      executionTip: 'Expose for the brightest part of the sky to turn the land into deep black silhouettes.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A nostalgic, soft-focus version with muted colors and a warm, grainy texture.',
      executionTip: 'Use a slightly wider aperture like f/4 to subtly soften the background and add a warm color overlay.',
    ),
  ],
  funFact: 'The \'Golden Hour\' occurs when the sun is low in the sky, meaning the light has to travel through more of the Earth\'s atmosphere, filtering out blue light and leaving those warm reds and oranges.',
  shareCaption: 'Chasing the light across these golden hills. There\'s nothing quite like the peace of a sunset walk. 🌅✨',
  tags: ['#landscapephotography', '#goldenhour', '#naturelovers', '#rollinghills', '#sunset', '#photographyguide', '#nextsnap', '#hikingadventures', '#scenicview'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
