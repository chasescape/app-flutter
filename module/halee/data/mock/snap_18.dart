import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData18 = SnapAnalysis(
  assetImg: A.assets_halee_18,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Landscape', confidence: 0.98, evidence: 'dramatic coastal cliffs and crashing ocean waves'),
    scene: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'natural rock formations and sea under a stormy sky'),
    lighting: SceneDimension(value: 'Overcast', confidence: 0.92, evidence: 'soft, diffused light coming through heavy cloud cover'),
    composition: SceneDimension(value: 'Leading Lines', confidence: 0.88, evidence: 'the coastline and wave patterns draw the eye from the foreground into the distance'),
    colorTone: SceneDimension(value: 'Dark & Moody', confidence: 0.96, evidence: 'deep blacks of the volcanic rock and desaturated grey-blue tones'),
    atmosphere: SceneDimension(value: 'Dramatic', confidence: 0.95, evidence: 'intense wave movement and brooding, heavy clouds'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a powerful capture that beautifully conveys the raw energy of the ocean using a skillful long exposure technique.',
    strengths: ['Excellent use of shutter speed to create silky water textures', 'Great choice of a dark, moody color palette that suits the weather', 'Compelling foreground detail in the wet volcanic rocks'],
    topImprovement: 'Try to find a more singular, distinct focal point in the foreground to anchor the viewer\'s gaze before it moves toward the cliffs.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Foreground Interest',
      title: 'Find a \'Hero\' Rock',
      action: 'Crouch down and position your lens closer to one specific, interesting rock formation in the immediate foreground.',
      expectedResult: 'Creates a stronger entry point for the eye and adds a sense of 3D depth to the scene.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Shoot from Knee-Height',
      action: 'Lower your tripod or camera to just above the ground level to make the foreground rocks appear larger and the waves more imposing.',
      expectedResult: 'Makes the viewer feel like they are standing right in the path of the spray, increasing the immersion.',
    ),
    ImprovementTip(
      category: 'Timing',
      title: 'Capture the \'Recession\'',
      action: 'Time your next shot for the exact moment a wave begins to pull back into the sea, rather than when it\'s crashing forward.',
      expectedResult: 'Produces beautiful white \'veins\' of water trailing through the rocks, leading the eye more effectively.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Fine Art',
      description: 'A high-contrast monochrome version that emphasizes the jagged textures of the stone against the soft white foam.',
      executionTip: 'Convert to black and white and increase the \'Clarity\' or \'Texture\' slider specifically on the dark rocks.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-screen panoramic crop that emphasizes the vastness of the horizon and the scale of the cliffs.',
      executionTip: 'Crop the image to a 2.35:1 aspect ratio and add a slight teal tint to the shadows of the water.',
    ),
    CreativeVariant(
      style: 'Motion Blur',
      description: 'An ethereal, mist-like sea where the water becomes a smooth white fog around the static rocks.',
      executionTip: 'Use a Neutral Density (ND) filter to extend your exposure time to 30 seconds or more for a completely surreal effect.',
    ),
  ],
  funFact: 'Long exposure photography was the standard in the 1830s because camera sensors (plates) were so slow—early landscape photographers often had to wait 10 minutes for a single shot!',
  shareCaption: 'Feeling the raw, unbridled power of the coast today. 🌊 There\'s something so calming about a storm. #NextSnap #NaturePhotography',
  tags: ['landscape', 'longexposure', 'seascape', 'moodygrams', 'oceanwaves', 'naturelovers', 'coastal', 'stormy'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
