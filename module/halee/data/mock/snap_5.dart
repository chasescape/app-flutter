import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData5 = SnapAnalysis(
  assetImg: A.assets_halee_5,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Portrait', confidence: 0.98, evidence: 'Young man focused on a laptop screen'),
    scene: SceneDimension(value: 'Home', confidence: 0.95, evidence: 'Indoor desk setup with a corkboard and houseplant'),
    lighting: SceneDimension(value: 'Artificial Warm', confidence: 0.98, evidence: 'Strong yellow glow from the desk lamp on the left'),
    composition: SceneDimension(value: 'Rule of Thirds', confidence: 0.9, evidence: 'Subject is positioned on the right vertical third of the frame'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.98, evidence: 'Dominant orange, brown, and yellow hues throughout'),
    atmosphere: SceneDimension(value: 'Cozy', confidence: 0.92, evidence: 'Soft lighting and comfortable indoor environment'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a wonderful shot that captures a quiet moment of deep focus with a beautifully warm, inviting atmosphere.',
    strengths: ['Excellent use of the desk lamp to create a moody, intimate feel', 'The background photos add great personal character without being distracting', 'Sharp focus on the subject\'s expression and glasses'],
    topImprovement: 'Try to balance the cool blue light from the laptop screen with the warm lamp to create a more dynamic color contrast on the subject\'s face.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your lens',
      action: 'Crouch down so your camera is level with the laptop keyboard rather than looking slightly down.',
      expectedResult: 'Creates a more immersive \'in the work\' feel and makes the viewer feel like they are sitting across from the subject.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Use the screen glow',
      action: 'For your next shot, dim the desk lamp slightly and increase the laptop screen brightness to let it cast a cool light on the subject\'s face.',
      expectedResult: 'Produces a more modern, tech-focused look with interesting dual-tone lighting on the skin.',
    ),
    ImprovementTip(
      category: 'Foreground Interest',
      title: 'Shoot through the plant',
      action: 'Physically move the plant on the right closer to the camera so a few leaves are blurred in the very front of the frame.',
      expectedResult: 'Adds a sense of depth and a \'fly-on-the-wall\' documentary feel to the composition.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Cinematic',
      description: 'A tight close-up on the subject\'s glasses, capturing the vivid reflection of the photo editing software on the lenses.',
      executionTip: 'Move in very close and lock your focus specifically on the eyes/glasses while keeping the background dark.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A grainier, slightly desaturated version with deeper shadows to evoke a nostalgic 90s study session vibe.',
      executionTip: 'Increase your camera\'s ISO or add digital grain in post-processing to mimic 35mm film stock.',
    ),
    CreativeVariant(
      style: 'Minimalist',
      description: 'A top-down \'flat lay\' shot showing only the hands on the keyboard and the warm pool of light on the wooden desk.',
      executionTip: 'Stand directly over the desk and frame the shot vertically to emphasize the textures of the wood and keys.',
    ),
  ],
  funFact: 'The \'warm\' light from your lamp is likely around 2700 Kelvin. Psychologically, this color temperature triggers the release of melatonin, which is why warm lighting feels so relaxing and \'homey\'.',
  shareCaption: 'Late nights and creative lights. 💡 Captured in the zone. #CreativeFlow',
  tags: ['portraitphotography', 'workfromhome', 'creativelife', 'deskinspiration', 'moodylighting', 'photographylovers', 'focused'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'The image contains a clear face and personal photos in the background. Ensure the subject has consented to sharing and consider blurring the background photos if they contain private info.',
  ),
);
