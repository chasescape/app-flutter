import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData20 = SnapAnalysis(
  assetImg: A.assets_halee_20,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Portrait', confidence: 0.95, evidence: 'Profile of a person merged with forest elements'),
    scene: SceneDimension(value: 'Nature', confidence: 0.98, evidence: 'Dense trees, leaves, and forest floor visible'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.92, evidence: 'Warm, low-angle sunlight filtering through the canopy'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.85, evidence: 'The subject\'s profile is the central focal point of the image'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.95, evidence: 'Dominant greens, browns, and golden highlights'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.9, evidence: 'Calm forest setting and peaceful facial expression'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a stunning double exposure that beautifully blends human form with the organic textures of the forest.',
    strengths: ['Excellent use of light to create depth within the silhouette', 'Seamless blending of tree bark and facial features', 'Compelling profile that guides the viewer\'s eye'],
    topImprovement: 'To make the silhouette even more defined, try shooting against a brighter, more uniform background like a clear sky.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Background',
      title: 'Seek higher contrast',
      action: 'For your next shot, position your subject against a bright sky or a light-colored wall for the base silhouette.',
      expectedResult: 'This makes the inner details of the second image much sharper and easier to see.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Use rim lighting',
      action: 'Place a light source or the sun directly behind the subject\'s head to create a thin \'halo\' of light around the hair.',
      expectedResult: 'Helps separate the subject from the dark forest background, adding more three-dimensional depth.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your angle',
      action: 'Crouch down and shoot slightly upwards toward the subject\'s chin.',
      expectedResult: 'Gives the portrait a more statuesque and powerful presence, emphasizing the \'rooted\' nature theme.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A clean, high-key version with a pure white background and only a few delicate branches inside the silhouette.',
      executionTip: 'Expose for the highlights of a bright window while the subject stands in front of it.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A moodier version with deep shadows and a single, strong light ray hitting the eye area for dramatic effect.',
      executionTip: 'Use a piece of cardboard with a small slit to create a \'god ray\' effect across the subject\'s face.',
    ),
    CreativeVariant(
      style: 'Fine Art',
      description: 'A high-contrast black and white version that focuses purely on the textures of the bark and skin.',
      executionTip: 'Convert to monochrome and boost the \'Texture\' and \'Clarity\' sliders to emphasize the organic details.',
    ),
  ],
  funFact: 'Double exposure was originally a happy accident in film photography when a photographer forgot to wind the film to the next frame!',
  shareCaption: 'Finding the forest within. 🌲✨ There\'s a whole world inside every one of us.',
  tags: ['doubleexposure', 'natureportrait', 'creativephotography', 'forestvibes', 'fineart', 'surrealism', 'goldenhour'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'The image contains a recognizable human profile. Mask the facial features if privacy is required before sharing.',
  ),
);
