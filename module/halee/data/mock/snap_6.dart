import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData6 = SnapAnalysis(
  assetImg: A.assets_halee_6,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Portrait', confidence: 0.98, evidence: 'Close-up of a human face showing eyes, nose, and lips.'),
    scene: SceneDimension(value: 'Indoor', confidence: 0.85, evidence: 'Controlled lighting and dark, non-descript background with soft bokeh.'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.92, evidence: 'Warm, low-angle light creating long, sharp shadows and a golden glow.'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.9, evidence: 'The face is centrally located, filling the majority of the vertical frame.'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.95, evidence: 'Dominant orange and yellow hues in the skin tones and highlights.'),
    atmosphere: SceneDimension(value: 'Dramatic', confidence: 0.9, evidence: 'High contrast between light and dark creates an intense, moody feel.'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a stunning high-contrast portrait that masterfully uses light and shadow to create depth and emotion.',
    strengths: ['Excellent focus on the eyes, drawing the viewer in immediately.', 'Beautiful warm color palette that feels rich and professional.', 'Strong use of chiaroscuro to define facial structure.'],
    topImprovement: 'Adjust the shadow placement so it doesn\'t cut directly through the eye to maintain a clearer gaze.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Lighting',
      title: 'Shift the shadow line',
      action: 'Slightly tilt the subject\'s head or move your light source so the shadow falls just above or below the eyes.',
      expectedResult: 'This keeps both eyes clearly visible and expressive while maintaining the dramatic mood.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Explore a side profile',
      action: 'Have the subject turn 90 degrees and shoot from the side, capturing the light hitting only the edge of the face.',
      expectedResult: 'Creates a striking silhouette effect that emphasizes the jawline and brow.',
    ),
    ImprovementTip(
      category: 'Composition',
      title: 'Use the Rule of Thirds',
      action: 'Step back slightly and position one of the eyes at the top-right or top-left intersection point of your grid.',
      expectedResult: 'Creates a more dynamic and balanced composition that feels less static than center-framing.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-angle shot showing the subject in a dimly lit room with a single beam of light hitting their face.',
      executionTip: 'Shoot in landscape orientation and add a slight blue tint to the shadows to create a \'teal and orange\' look.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A softer, grainier version of this shot that feels like a frame from an old 35mm movie.',
      executionTip: 'Lower the contrast slightly and add a warm, desaturated yellow overlay in post-processing.',
    ),
    CreativeVariant(
      style: 'Fine Art',
      description: 'A high-contrast black and white study focusing entirely on the geometry of the shadows.',
      executionTip: 'Remove all color and increase the \'Blacks\' setting to make the dark areas merge into the background.',
    ),
  ],
  funFact: 'The lighting style you used is often called \'Chiaroscuro,\' a technique used by Renaissance painters like Caravaggio to create a sense of volume and drama.',
  shareCaption: 'Dancing with shadows and chasing that golden glow. ✨',
  tags: ['portraitphotography', 'goldenhour', 'shadowplay', 'chiaroscuro', 'moodyports', 'naturallight', 'nextsnap'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'The image contains a clear view of a person\'s face. Ensure you have permission before sharing, or apply a light blur to the eyes if identity protection is needed.',
  ),
);
