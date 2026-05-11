import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData2 = SnapAnalysis(
  assetImg: A.assets_halee_2,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Architecture', confidence: 0.98, evidence: 'Multiple high-rise skyscrapers dominate the frame.'),
    scene: SceneDimension(value: 'Urban', confidence: 0.99, evidence: 'City skyline with a paved waterfront promenade.'),
    lighting: SceneDimension(value: 'Blue Hour', confidence: 0.92, evidence: 'Deep blue sky combined with glowing artificial lights from buildings.'),
    composition: SceneDimension(value: 'Layered', confidence: 0.88, evidence: 'Foreground reflections, mid-ground railing, and background skyscrapers create depth.'),
    colorTone: SceneDimension(value: 'Cool', confidence: 0.95, evidence: 'Dominant blue palette with contrasting warm yellow and red light accents.'),
    atmosphere: SceneDimension(value: 'Mysterious', confidence: 0.85, evidence: 'Fog-shrouded building tops and dark, wet surfaces.'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a moody and well-timed shot that captures the city\'s scale through beautiful reflections and atmospheric fog.',
    strengths: ['Excellent use of the wet pavement to double the visual interest', 'The fog at the top of the buildings adds a great sense of height and mystery', 'Strong vertical alignment maintains a professional look'],
    topImprovement: 'Lowering your perspective would make the reflections even more dominant and immersive.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Get closer to the ground',
      action: 'Crouch down or place your camera lens just an inch above the wet pavement.',
      expectedResult: 'This will make the reflections appear to stretch toward the viewer, creating a more powerful \'mirror\' effect.',
    ),
    ImprovementTip(
      category: 'Composition',
      title: 'Use the Rule of Thirds',
      action: 'Shift your frame so the main central tower sits slightly to the left or right of the center line.',
      expectedResult: 'Creates a more dynamic and balanced composition that leads the eye through the scene.',
    ),
    ImprovementTip(
      category: 'Camera Settings',
      title: 'Steady your shot',
      action: 'Rest your phone on the railing or a tripod and use a 2-second timer to avoid \'camera shake\' blur.',
      expectedResult: 'Sharper details in the building windows and cleaner textures in the reflections.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-screen view that emphasizes the glow of the neon lights against the dark blue fog.',
      executionTip: 'Crop the image to a 16:9 aspect ratio and slightly increase the \'Glow\' or \'Bloom\' in post-processing.',
    ),
    CreativeVariant(
      style: 'Abstract',
      description: 'A colorful, distorted image focusing entirely on the light patterns in the puddles.',
      executionTip: 'Point your camera straight down at the ground and fill the entire frame with the rippled reflections.',
    ),
    CreativeVariant(
      style: 'Symmetrical',
      description: 'A perfectly balanced shot where the horizon line is dead-center, mirroring the sky and ground.',
      executionTip: 'Find a large, still puddle and align the base of the buildings exactly in the middle of the frame.',
    ),
  ],
  funFact: 'Wet pavement has a much higher \'specular reflection\' than dry ground, essentially turning the city streets into a giant light-modifier for your camera.',
  shareCaption: 'Chasing the blue hour glow. 🌃 The city looks even better when it\'s twice as bright. #NextSnap',
  tags: ['cityscape', 'nightphotography', 'bluehour', 'reflections', 'architecture', 'urbanvibes', 'rainycity'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
