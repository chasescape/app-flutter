import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData13 = PlantAnalysis(
  assetImg: A.assets_lenbo_13,
  plantId: PlantId(
    commonName: 'Variegated Rubber Plant',
    scientificName: 'Ficus elastica \'Tineke\'',
    family: 'Moraceae',
    otherNames: ['Rubber Tree', 'Rubber Fig'],
    identificationConfidence: 0.95,
    funFact: 'In their native tropical habitats, these plants can grow into massive trees over 100 feet tall with impressive aerial roots!',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.9,
    visualEvidence: 'The leaves appear firm, glossy, and vibrant with no signs of pests, wilting, or brown edges.',
    symptoms: [],
    overallImpression: 'Your plant looks absolutely stunning and appears to be thriving in its current spot!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Unknown',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '15+ years',
    maxHeight: '6-10 feet indoors',
  ),
  careGuide: CareGuide(
    summary: 'A hardy and stylish indoor favorite that rewards bright light with beautiful, painterly leaf patterns.',
    watering: WateringGuide(
      frequency: 'Every 10-14 Days',
      method: 'Water thoroughly until it drains out the bottom, but only once the top 2 inches of soil feel dry.',
      seasonalNote: 'Reduce watering in winter when growth slows down.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, filtered light is best to keep the white variegation sharp and bright.',
      currentAssessment: 'The plant is getting good light, but ensure the direct sun through the window doesn\'t scorch the leaves.',
      adjustmentTip: 'If new leaves come out solid green, it needs a bit more light.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during the growing season (Spring through Summer).',
      recommendedType: 'Balanced liquid houseplant fertilizer.',
      seasonalNote: 'Stop fertilizing during the dormant winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F',
      tolerance: 'Sensitive to cold drafts; keep above 55°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Moderate',
      boostMethods: ['Wipe leaves with a damp cloth', 'Place near other plants'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Leaf Drop',
      cause: 'Sudden temperature changes or overwatering.',
      prevention: 'Avoid placing near AC vents or heaters.',
      fix: 'Move to a stable location and let the soil dry out.',
    ),
    CommonIssue(
      problem: 'Fading Variegation',
      cause: 'Not enough light.',
      prevention: 'Keep in a bright room near a window.',
      fix: 'Gradually move to a brighter spot to encourage color.',
    ),
  ],
  proTip: 'Wipe the leaves regularly with a damp cloth! Dust blocks sunlight and prevents the plant from \'breathing\' properly.',
  plantPersonality: 'This chic and sturdy companion is a natural showstopper that brings a sophisticated, tropical vibe to any room.',
  safety: SafetyInfo(
    toxicityNote: 'The milky sap can cause skin irritation and is toxic if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of cats, dogs, and small children.',
  ),
);
