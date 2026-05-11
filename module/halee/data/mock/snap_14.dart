import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData14 = SnapAnalysis(
  assetImg: A.assets_halee_14,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Animal', confidence: 0.98, evidence: 'Close-up portrait of a Golden Retriever'),
    scene: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'Soft green blurred grass in the background'),
    lighting: SceneDimension(value: 'Natural Soft', confidence: 0.92, evidence: 'Gentle, diffused light with a subtle warm glow from the upper left'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.98, evidence: 'The dog\'s face is positioned directly in the center of the frame'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.94, evidence: 'Golden fur tones and warm highlight in the corner'),
    atmosphere: SceneDimension(value: 'Fresh', confidence: 0.9, evidence: 'Bright, happy expression and clean outdoor setting'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a lovely, high-quality pet portrait with excellent focus on the eyes and a beautiful creamy background.',
    strengths: ['Perfect sharp focus on the dog\'s eyes and nose', 'Excellent use of shallow depth of field to isolate the subject', 'Pleasant, warm lighting that complements the fur color'],
    topImprovement: 'Try moving the subject off-center to create a more professional, dynamic composition.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Composition',
      title: 'Use the Rule of Thirds',
      action: 'Next time, frame the shot so the dog\'s eyes are aligned with the top-right or top-left intersection points of your camera grid.',
      expectedResult: 'Creates a more balanced and visually engaging image that feels less like a snapshot.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Get even lower',
      action: 'Crouch all the way down or place your phone on the grass to shoot from a slightly upward angle.',
      expectedResult: 'Makes the dog appear more heroic and provides a more immersive \'dog\'s eye view\' of the world.',
    ),
    ImprovementTip(
      category: 'Framing',
      title: 'Give \'Lead Room\'',
      action: 'Leave more empty space in the direction the dog\'s nose is pointing.',
      expectedResult: 'Gives the subject space to \'look into,\' making the composition feel more natural and less cramped.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A tight, abstract crop focusing only on the textures of the nose and whiskers.',
      executionTip: 'Move in as close as your lens allows or use a macro mode to capture the fine details of the fur.',
    ),
    CreativeVariant(
      style: 'Storytelling',
      description: 'An action shot of the dog running toward the camera with ears flapping.',
      executionTip: 'Use \'Burst Mode\' and a fast shutter speed to freeze the motion and capture a candid, energetic moment.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-angle shot with the dog sitting on one side of a vast, open field during sunset.',
      executionTip: 'Step back significantly and use a wider lens to capture the scale of the environment around your subject.',
    ),
  ],
  funFact: 'A dog\'s nose print is as unique as a human fingerprint and can actually be used to identify them!',
  shareCaption: 'Just a golden soul enjoying a golden afternoon. 🐾✨',
  tags: ['goldenretriever', 'dogphotography', 'petportrait', 'goldenhour', 'animalportraits', 'bokeh', 'naturephotography'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
