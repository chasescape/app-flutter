import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData15 = PlantAnalysis(
  assetImg: A.assets_lenbo_15,
  plantId: PlantId(
    commonName: 'Sweet Basil',
    scientificName: 'Ocimum basilicum',
    family: 'Lamiaceae',
    otherNames: ['Genovese Basil', 'Great Basil'],
    identificationConfidence: 0.98,
    funFact: 'In ancient times, some cultures believed basil would only grow if you shouted and cursed while sowing the seeds!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant green leaves with a glossy finish, sturdy upright stems, and no visible spotting or pests.',
    symptoms: [],
    overallImpression: 'Your basil is thriving and looks perfectly cared for in its current sunny spot.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '1 year (Annual)',
    maxHeight: '12-24 inches',
  ),
  careGuide: CareGuide(
    summary: 'Basil is a sun-loving herb that rewards consistent watering and regular harvesting with lush, aromatic foliage.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Days',
      method: 'Water at the base of the plant to keep leaves dry and prevent fungal growth.',
      seasonalNote: 'Soil dries out faster in summer; check daily during heatwaves.',
    ),
    light: LightGuide(
      idealCondition: '6-8 hours of bright, filtered light daily.',
      currentAssessment: 'The windowsill placement is ideal for steady growth.',
      adjustmentTip: 'Rotate the pot 90 degrees every few days to ensure even growth on all sides.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 4 weeks',
      recommendedType: 'Balanced liquid organic fertilizer',
      seasonalNote: 'Only fertilize during the active growing season (Spring/Summer).',
    ),
    temperature: TemperatureGuide(
      idealRange: '70°F - 85°F',
      tolerance: 'Extremely frost-sensitive; keep away from cold window drafts.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Moderate (40-60%)',
      boostMethods: ['Group with other herbs', 'Use a nearby pebble tray'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Leaf Wilting',
      cause: 'Dry soil or high heat stress.',
      prevention: 'Maintain consistent soil moisture.',
      fix: 'Provide a deep soak until water runs out the drainage holes.',
    ),
    CommonIssue(
      problem: 'Yellowing Lower Leaves',
      cause: 'Over-watering or lack of nitrogen.',
      prevention: 'Allow top inch of soil to dry slightly before watering.',
      fix: 'Reduce watering frequency and check for proper pot drainage.',
    ),
    CommonIssue(
      problem: 'Bolting (Flowering)',
      cause: 'High temperatures or natural maturity.',
      prevention: 'Regularly pinch off flower buds as they appear.',
      fix: 'Harvest leaves immediately, as they can become bitter once the plant flowers.',
    ),
  ],
  proTip: 'Pinch off the top set of leaves every time a branch has 6-8 leaves; this forces the plant to branch out and become bushier rather than tall and leggy.',
  plantPersonality: 'This kitchen companion is the ultimate social butterfly—it loves the spotlight and rewards your attention with a delicious aroma.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'Safe for both cats and dogs.',
  ),
);
