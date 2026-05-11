import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData3 = SnapAnalysis(
  assetImg: A.assets_halee_3,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Nature', confidence: 0.98, evidence: 'macro shot of a water droplet on a green leaf'),
    scene: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'natural leaf texture and outdoor sunlight'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.92, evidence: 'warm yellow glow and soft backlighting from the top'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.85, evidence: 'droplet is positioned exactly in the horizontal center'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.95, evidence: 'dominant yellow and vibrant green hues'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.9, evidence: 'still water and soft out-of-focus background'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'A breathtaking macro shot that beautifully captures the clarity of a water droplet against a warm, glowing backdrop.',
    strengths: ['Excellent focus and clarity on the main droplet', 'Beautifully creamy background bokeh', 'Perfect use of backlighting to create a \'halo\' effect'],
    topImprovement: 'Try shifting the subject away from the dead center to create a more dynamic and professional composition.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Subject Placement',
      title: 'Apply the Rule of Thirds',
      action: 'Move your camera slightly so the droplet sits on the left or right vertical third of your frame rather than the center.',
      expectedResult: 'Creates a more balanced and visually interesting story by giving the droplet \'room\' to exist in the landscape.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Get perfectly level',
      action: 'Lower your lens just a few millimeters more until you are looking directly through the side of the droplet.',
      expectedResult: 'Enhances the \'crystal ball\' effect and captures a clearer refraction of the background inside the water.',
    ),
    ImprovementTip(
      category: 'Framing',
      title: 'Use foreground depth',
      action: 'Position another leaf or blade of grass very close to the lens to create a soft, blurred frame in the bottom corner.',
      expectedResult: 'Adds a sense of three-dimensional depth and makes the viewer feel like they are peeking into a secret world.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A clean shot focusing only on the droplet and one single leaf vein against a solid background.',
      executionTip: 'Use a wider aperture to completely blur out the surrounding leaf texture until it becomes a smooth wash of color.',
    ),
    CreativeVariant(
      style: 'Abstract',
      description: 'An extreme close-up focusing on the inverted world reflected inside the water droplet itself.',
      executionTip: 'Place a colorful flower behind the droplet and focus specifically on the reflection within the water.',
    ),
    CreativeVariant(
      style: 'Storytelling',
      description: 'Capturing the moment just before the droplet falls or as an insect approaches it.',
      executionTip: 'Gently nudge the leaf or wait for a slight breeze to capture the droplet in motion.',
    ),
  ],
  funFact: 'Water droplets act like tiny wide-angle lenses; the image you see inside them is actually the background flipped upside down and shrunk!',
  shareCaption: 'Finding the magic in the smallest details. Nature\'s crystal ball caught in the morning glow. ✨',
  tags: ['macrophotography', 'naturelovers', 'goldenhour', 'waterdroplets', 'bokeh', 'details', 'morningdew', 'nextsnap'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
