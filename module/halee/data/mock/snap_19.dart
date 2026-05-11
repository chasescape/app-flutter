import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData19 = SnapAnalysis(
  assetImg: A.assets_halee_19,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Landscape', confidence: 0.98, evidence: 'winding river through a deep green valley'),
    scene: SceneDimension(value: 'Nature', confidence: 0.99, evidence: 'forested hills, river, and wildflowers'),
    lighting: SceneDimension(value: 'Natural Soft', confidence: 0.9, evidence: 'diffused sunlight through clouds hitting the valley floor'),
    composition: SceneDimension(value: 'Leading Lines', confidence: 0.95, evidence: 'the S-curve of the river leads the eye through the frame'),
    colorTone: SceneDimension(value: 'Vibrant', confidence: 0.95, evidence: 'saturated greens and bright yellow and purple flowers'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.92, evidence: 'calm river and lush, peaceful landscape'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a stunning landscape shot that beautifully captures the scale and serenity of the valley using the river as a perfect visual guide.',
    strengths: ['Excellent use of the \'S-curve\' leading line to create depth', 'Foreground wildflowers add a lovely layer of color and interest', 'Vibrant green tones feel fresh and inviting'],
    topImprovement: 'To add more drama, try capturing this scene when the sun is lower in the sky to create longer shadows and highlight the texture of the hills.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Timing',
      title: 'Wait for the \'Golden Hour\'',
      action: 'Stay at this location until about 30 minutes before sunset. This will provide warmer light and cast long shadows across the ridges.',
      expectedResult: 'Adds dramatic contrast and emphasizes the three-dimensional texture of the canyon walls.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your perspective',
      action: 'Crouch down lower to the ground so the wildflowers are closer to the lens. Ensure the river is still visible in the background.',
      expectedResult: 'Creates a more immersive \'first-person\' feel, making the viewer feel like they are sitting in the meadow.',
    ),
    ImprovementTip(
      category: 'Camera Settings',
      title: 'Maximize your depth of field',
      action: 'If using a manual camera, set your aperture to a higher f-number like f/11 or f/16. Keep your focus point about one-third of the way into the scene.',
      expectedResult: 'Ensures everything from the tiny flowers in front to the distant mountains stays tack-sharp.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-screen view with deeper shadows and high-contrast lighting.',
      executionTip: 'Shoot in a 16:9 aspect ratio and slightly underexpose the image to keep the highlights on the river from blowing out.',
    ),
    CreativeVariant(
      style: 'Minimalist',
      description: 'A tight crop focusing on just one elegant curve of the river and the surrounding grass.',
      executionTip: 'Zoom in to remove the sky and foreground flowers, focusing entirely on the geometry of the water and the meadow.',
    ),
    CreativeVariant(
      style: 'Reflection',
      description: 'A shot focusing on the sky and hills mirrored in the river\'s surface.',
      executionTip: 'Find a calm day and move closer to the water\'s edge to capture the reflection of the clouds in the S-curve.',
    ),
  ],
  funFact: 'The \'S-curve\' is a classic composition tool because it mimics the natural movement of the human eye, making images feel more fluid and graceful.',
  shareCaption: 'Finding my flow in the heart of the valley. 🌿✨ Nature\'s geometry is the best kind of art.',
  tags: ['landscapephotography', 'naturelovers', 'valleyview', 'leadinglines', 'wildflowers', 'adventure', 'greenery', 'riverview'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
