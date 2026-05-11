import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData11 = PlantAnalysis(
  assetImg: A.assets_lenbo_11,
  plantId: PlantId(
    commonName: 'Sweet Basil',
    scientificName: 'Ocimum basilicum',
    family: 'Lamiaceae',
    otherNames: ['Genovese Basil', 'Common Basil'],
    identificationConfidence: 0.98,
    funFact: 'Basil is a member of the mint family and its name is derived from the Greek word for \'kingly\' or \'royal\'.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green leaves, sturdy upright stems, and uniform growth across all seedlings.',
    symptoms: [],
    overallImpression: 'These seedlings are in excellent condition and thriving in their current environment.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Seedling',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '1 year (Annual)',
    maxHeight: '12-24 inches',
  ),
  careGuide: CareGuide(
    summary: 'Basil loves sun, warmth, and consistent moisture. It is a rewarding herb that grows quickly from this seedling stage.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Water at the base of the plant to keep the leaves dry, which helps prevent fungal issues.',
      seasonalNote: 'In hot summer weather, check daily as small pots dry out very quickly.',
    ),
    light: LightGuide(
      idealCondition: '6-8 hours of bright sunlight daily.',
      currentAssessment: 'The greenhouse setting provides perfect diffused light for these young plants.',
      adjustmentTip: 'If moving to a windowsill, choose a south-facing window for maximum sun exposure.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 2 weeks',
      recommendedType: 'Diluted liquid organic fertilizer',
      seasonalNote: 'Only fertilize during the active growing season; stop if the plant begins to flower.',
    ),
    temperature: TemperatureGuide(
      idealRange: '70°F - 85°F',
      tolerance: 'Very sensitive to cold; keep above 50°F at all times.',
    ),
    humidity: HumidityGuide(
      idealLevel: '40-60%',
      boostMethods: ['Group plants together', 'Pebble tray'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Leggy Stems',
      cause: 'Searching for more light.',
      prevention: 'Ensure at least 6 hours of direct sun or bright grow lights.',
      fix: 'Pinch off the top set of leaves to encourage branching.',
    ),
    CommonIssue(
      problem: 'Yellowing Lower Leaves',
      cause: 'Overwatering or nitrogen deficiency.',
      prevention: 'Allow the top inch of soil to dry slightly before watering.',
      fix: 'Improve drainage and apply a balanced liquid fertilizer.',
    ),
  ],
  proTip: 'Always harvest leaves from the top of the plant rather than the bottom; this prevents \'bolting\' and encourages a bushier shape.',
  plantPersonality: 'This aromatic overachiever is eager to please and will reward your care with enough leaves for a fresh batch of pesto.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns. Safe for culinary use and pet-friendly.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: '',
  ),
);
