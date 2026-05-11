import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData10 = PlantAnalysis(
  assetImg: A.assets_lenbo_10,
  plantId: PlantId(
    commonName: 'Moth Orchid',
    scientificName: 'Phalaenopsis',
    family: 'Orchidaceae',
    otherNames: ['Phal', 'Butterfly Orchid'],
    identificationConfidence: 0.98,
    funFact: 'In their natural habitat, these orchids are epiphytes, meaning they grow on trees rather than in soil, using their roots to cling to bark.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant purple blooms, firm and upright green leaves, and healthy-looking aerial roots visible at the base.',
    symptoms: [],
    overallImpression: 'This orchid is in peak condition and looks absolutely stunning in its flowering stage.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Slightly Dry',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Flowering',
    difficultyLevel: 'Moderate',
    expectedLifespan: '10-15 years',
    maxHeight: '2-3 feet',
  ),
  careGuide: CareGuide(
    summary: 'Moth orchids love consistency, bright filtered light, and high humidity to keep their blooms lasting for months.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Soak the orchid\'s inner pot in room-temperature water for 15 minutes, then drain completely. Avoid getting water in the \'crown\' (center of leaves).',
      seasonalNote: 'Reduce watering slightly in winter when growth slows, but don\'t let the orchid dry out completely.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, indirect light near an east or west-facing window.',
      currentAssessment: 'The current lighting appears ideal, supporting healthy flower production.',
      adjustmentTip: 'If leaves turn dark green, it needs more light; if they turn yellow or red, it’s getting too much sun.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every two weeks',
      recommendedType: 'Balanced orchid-specific fertilizer diluted to half strength.',
      seasonalNote: 'Feed \'weakly, weekly\' during the growing season and reduce to once a month during winter.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 80°F',
      tolerance: 'Avoid temperatures below 55°F or sudden cold drafts.',
    ),
    humidity: HumidityGuide(
      idealLevel: '50-70%',
      boostMethods: ['Place on a pebble tray with water', 'Group with other plants', 'Use a room humidifier'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Bud Blast',
      cause: 'Sudden changes in temperature, humidity, or drafts causing unopened buds to fall off.',
      prevention: 'Keep the plant away from AC vents, heaters, or drafty doors.',
      fix: 'Stabilize the environment and maintain consistent humidity levels.',
    ),
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or leaving the roots sitting in stagnant water.',
      prevention: 'Always use a well-draining orchid bark mix and a pot with drainage holes.',
      fix: 'Trim away mushy brown roots and repot in fresh, dry orchid bark.',
    ),
    CommonIssue(
      problem: 'Sunburn',
      cause: 'Exposure to direct, harsh afternoon sunlight.',
      prevention: 'Use a sheer curtain to filter direct sun.',
      fix: 'Move the plant to a spot with softer, indirect light; damaged leaves will not heal but new ones will grow.',
    ),
  ],
  proTip: 'To encourage a second flush of flowers, once the current blooms fade, cut the flower spike just above the second \'node\' (the little bump on the stem) from the bottom.',
  plantPersonality: 'The elegant diva of the plant world—she appreciates a steady routine and will reward your attention with months of spectacular, graceful color.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns. Phalaenopsis orchids are generally considered safe for households with pets.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'Safe for cats and dogs, but it\'s still best to keep them from chewing on the leaves to avoid upset stomachs.',
  ),
);
