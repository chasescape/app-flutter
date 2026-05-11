import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData15 = SnapAnalysis(
  assetImg: A.assets_halee_15,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Landscape', confidence: 0.95, evidence: 'vast mountain range with a person overlooking a valley'),
    scene: SceneDimension(value: 'Mountain', confidence: 0.98, evidence: 'jagged peaks, steep cliffs, and a deep alpine valley'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.95, evidence: 'vibrant orange and pink clouds with warm light hitting the cliffside'),
    composition: SceneDimension(value: 'Layered', confidence: 0.9, evidence: 'foreground rocks, mid-ground valley, and background mountain peaks create depth'),
    colorTone: SceneDimension(value: 'Vibrant', confidence: 0.92, evidence: 'high saturation in the sunset sky and lush green valley'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.85, evidence: 'quiet, expansive view of nature at dusk'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a breathtaking landscape shot that perfectly uses a human element to provide a sense of scale against the massive mountain backdrop.',
    strengths: ['Excellent use of foreground elements to lead the eye into the scene', 'Perfect timing capturing the peak colors of the sunset', 'Strong storytelling by including the photographer as a focal point'],
    topImprovement: 'To make the composition even cleaner, try to step slightly to the right to prevent the wooden fence from being cut off at the edge of the frame.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Framing',
      title: 'Clear the edges',
      action: 'Step one pace to your right or tilt the camera slightly to ensure the wooden fence post isn\'t touching the very edge of the frame.',
      expectedResult: 'Reduces visual tension and keeps the viewer\'s focus on the center of the image.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your camera height',
      action: 'Crouch down closer to the rocky ledge while keeping the photographer in the frame.',
      expectedResult: 'Makes the cliff look more dramatic and emphasizes the height of the mountain peaks.',
    ),
    ImprovementTip(
      category: 'Timing',
      title: 'Capture the valley lights',
      action: 'Wait another 15 minutes for the \'Blue Hour\' when the village lights in the valley become more prominent against the darkening earth.',
      expectedResult: 'Adds a secondary point of interest and a beautiful contrast between human life and wild nature.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Silhouette',
      description: 'A dramatic version where the photographer and the foreground rocks are completely black against the glowing sky.',
      executionTip: 'Tap on the brightest part of the sky on your screen to lock exposure before taking the shot.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-screen look that emphasizes the horizontal vastness of the mountain range.',
      executionTip: 'Crop the image to a 21:9 aspect ratio, removing some of the sky and the very bottom of the rocks.',
    ),
    CreativeVariant(
      style: 'Documentary',
      description: 'A candid shot focusing on the photographer\'s interaction with her gear.',
      executionTip: 'Move closer to the subject and use a wider aperture to slightly blur the background while keeping her camera in sharp focus.',
    ),
  ],
  funFact: 'The \'Alpenglow\' effect happens when the sun is just below the horizon; the light reflects off airborne particles to create that signature pink glow on mountain tops.',
  shareCaption: 'Finding perspective where the peaks meet the clouds. 🏔️✨ Nature\'s best show is always at sunset.',
  tags: ['LandscapePhotography', 'MountainVibes', 'GoldenHour', 'AdventureAwaits', 'SunsetLovers', 'NatureGram', 'ExploreMore'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'A person\'s profile is visible. If this is a stranger, consider blurring the facial features before public sharing.',
  ),
);
