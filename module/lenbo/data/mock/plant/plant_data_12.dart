import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData12 = PlantAnalysis(
  assetImg: A.assets_lenbo_12,
  plantId: PlantId(
    commonName: 'Mexican Snowball',
    scientificName: 'Echeveria elegans',
    family: 'Crassulaceae',
    otherNames: ['White Rose', 'Hen and Chicks'],
    identificationConfidence: 0.95,
    funFact: 'This plant produces a powdery coating called farina that acts as a natural sunscreen and water repellent for its leaves.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.98,
    visualEvidence: 'The rosette is tight and symmetrical with plump, firm leaves and no signs of stretching or discoloration.',
    symptoms: [],
    overallImpression: 'Your Echeveria looks exceptionally vibrant and well-cared for in its sunny spot!',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Direct',
    soilMoistureVisual: 'Dry',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Mature',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: 'Many years through offsets',
    maxHeight: '4-8 inches',
  ),
  careGuide: CareGuide(
    summary: 'A hardy, sun-loving succulent that prefers deep but infrequent watering and plenty of light.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Weeks',
      method: 'Use the \'soak and dry\' method: water the soil directly until it drains, then let it dry out completely.',
      seasonalNote: 'Reduce watering to once a month during winter dormancy.',
    ),
    light: LightGuide(
      idealCondition: 'Full sun to bright indirect light for at least 6 hours daily.',
      currentAssessment: 'Perfectly placed on a bright windowsill.',
      adjustmentTip: 'Rotate the pot weekly so all sides get equal sun exposure.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during spring and summer.',
      recommendedType: 'Liquid succulent fertilizer diluted to half-strength.',
      seasonalNote: 'Do not fertilize during the winter.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 80°F',
      tolerance: 'Protect from frost; can tolerate down to 40°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Low humidity',
      boostMethods: ['Maintain good air circulation', 'Keep away from humid bathrooms'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or sitting in damp soil.',
      prevention: 'Use well-draining cactus mix and a pot with a drainage hole.',
      fix: 'Remove from soil, trim mushy roots, and repot in fresh, dry soil.',
    ),
    CommonIssue(
      problem: 'Etiolation (Stretching)',
      cause: 'Insufficient light causing the plant to grow tall and thin.',
      prevention: 'Ensure it receives at least 6 hours of bright light.',
      fix: 'Move to a sunnier spot; leggy plants can be \'beheaded\' to grow a new rosette.',
    ),
  ],
  proTip: 'Avoid touching the leaves with your fingers, as the oils from your skin can smudge the protective powdery farina coating.',
  plantPersonality: 'This resilient little gem is the ultimate low-maintenance companion, rewarding your patience with its perfect geometric beauty.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'Safe for households with curious cats and dogs.',
  ),
);
