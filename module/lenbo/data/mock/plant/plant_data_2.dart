import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData2 = PlantAnalysis(
  assetImg: A.assets_lenbo_2,
  plantId: PlantId(
    commonName: 'Peace Lily',
    scientificName: 'Spathiphyllum',
    family: 'Araceae',
    otherNames: ['Mauna Loa', 'White Sails', 'Spath'],
    identificationConfidence: 0.92,
    funFact: 'Peace Lilies are famous for being \'drama queens\' because they wilt dramatically when thirsty, only to bounce back completely within hours of being watered.',
  ),
  healthCheck: HealthCheck(
    status: 'Needs Attention',
    confidence: 0.95,
    visualEvidence: 'The soil is severely parched, compacted, and showing deep cracks, indicating extreme dehydration despite the leaves still appearing green.',
    symptoms: ['Severely cracked soil', 'Soil pulling away from pot edges', 'Likely hydrophobic soil'],
    overallImpression: 'Your plant is in urgent need of deep hydration; while the leaves look okay now, the soil is bone-dry and will soon cause wilting.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Dry',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Young',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '3-5 years',
    maxHeight: '1-4 feet',
  ),
  careGuide: CareGuide(
    summary: 'A resilient indoor favorite known for its air-purifying qualities and ability to communicate its needs clearly.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Use the \'soak and drain\' method. Submerge the pot in a basin of water for 15 minutes to rehydrate the compacted soil.',
      seasonalNote: 'Keep soil consistently moist but not soggy. Water slightly less in winter.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, filtered light is best. Avoid direct afternoon sun.',
      currentAssessment: 'The light level looks good, but the heat from the light may be drying the soil out too quickly.',
      adjustmentTip: 'If the soil dries this fast, try moving it a foot further from the light source.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 6-8 weeks',
      recommendedType: 'Balanced liquid fertilizer at half strength.',
      seasonalNote: 'Only fertilize during the active growing season (spring and summer).',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 80°F',
      tolerance: 'Keep away from cold drafts and temperatures below 55°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (50% or above)',
      boostMethods: ['Mist the leaves daily', 'Use a pebble tray with water', 'Group with other plants'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Hydrophobic Soil',
      cause: 'Soil becoming so dry it repels water rather than absorbing it.',
      prevention: 'Never let the soil get dry enough to crack.',
      fix: 'Poke small holes in the soil with a chopstick and bottom-water for 20 minutes.',
    ),
    CommonIssue(
      problem: 'Brown Leaf Tips',
      cause: 'Low humidity or sensitivity to chemicals in tap water.',
      prevention: 'Use filtered or distilled water.',
      fix: 'Trim brown tips with clean shears and increase local humidity.',
    ),
    CommonIssue(
      problem: 'Yellowing Leaves',
      cause: 'Overwatering or poor drainage leading to root rot.',
      prevention: 'Ensure the pot has drainage holes and the soil is airy.',
      fix: 'Allow the top inch of soil to dry before watering again.',
    ),
  ],
  proTip: 'When the soil is this dry, water will often run down the sides of the pot without reaching the roots. Always double-check the weight of the pot after watering to ensure it feels heavy and saturated.',
  plantPersonality: 'The ultimate communicator—she’ll tell you exactly when she’s thirsty with a dramatic wilt, but she’s incredibly forgiving once she gets a drink.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are irritating if chewed or swallowed.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of cats and dogs as ingestion can cause mouth irritation and drooling.',
  ),
);
