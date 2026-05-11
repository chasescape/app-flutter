import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData20 = PlantAnalysis(
  assetImg: A.assets_lenbo_20,
  plantId: PlantId(
    commonName: 'Peace Lily',
    scientificName: 'Spathiphyllum',
    family: 'Araceae',
    otherNames: ['White Sails', 'Spath'],
    identificationConfidence: 0.98,
    funFact: 'Peace Lilies aren\'t true lilies; they are tropical evergreens that actually help clean the air of indoor toxins like benzene and formaldehyde.',
  ),
  healthCheck: HealthCheck(
    status: 'Needs Attention',
    confidence: 0.9,
    visualEvidence: 'Noticeable brown, crispy tips and edges on several leaves, though new white blooms are present.',
    symptoms: ['Brown leaf tips', 'Dry leaf margins', 'Slight yellowing on lower leaves'],
    overallImpression: 'Your Peace Lily is showing off beautiful blooms, but those crispy brown tips suggest it\'s a bit thirsty for humidity or cleaner water.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Slightly Dry',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Flowering',
    difficultyLevel: 'Beginner-Friendly',
    expectedLifespan: '5-10 years',
    maxHeight: '1-4 feet depending on variety',
  ),
  careGuide: CareGuide(
    summary: 'A resilient indoor favorite that communicates its needs clearly through its leaves.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Water thoroughly until it drains from the bottom. They love to be kept consistently moist but not soggy.',
      seasonalNote: 'Reduce watering slightly in winter, but never let the soil dry out completely.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, indirect light is best. Avoid direct afternoon sun which can scorch the leaves.',
      currentAssessment: 'The current spot near the window seems good, but ensure it\'s not getting hit by direct rays.',
      adjustmentTip: 'If the leaves turn pale or yellow, it might be getting too much light.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every 6 weeks during spring and summer.',
      recommendedType: 'Balanced liquid fertilizer diluted to half strength.',
      seasonalNote: 'Stop fertilizing during the winter months when growth slows.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 80°F (18°C - 27°C)',
      tolerance: 'Keep away from cold drafts and temperatures below 55°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'High (50% or more)',
      boostMethods: ['Mist leaves regularly', 'Place on a pebble tray with water', 'Group with other plants'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Brown Leaf Tips',
      cause: 'Low humidity or sensitivity to chemicals like fluoride in tap water.',
      prevention: 'Use filtered or distilled water and increase humidity.',
      fix: 'Trim the brown tips with clean scissors and switch to filtered water.',
    ),
    CommonIssue(
      problem: 'Drooping Leaves',
      cause: 'Underwatering or the plant is completely dry.',
      prevention: 'Check soil moisture weekly.',
      fix: 'Give it a good soak; it should perk back up within a few hours.',
    ),
  ],
  proTip: 'If your Peace Lily stops blooming, try moving it to a slightly brighter spot; they need adequate light to produce those iconic white spathes.',
  plantPersonality: 'The \'Drama Queen\' of the plant world—she\'ll wilt dramatically when thirsty just to let you know, but she recovers beautifully with a little drink.',
  safety: SafetyInfo(
    toxicityNote: 'Contains calcium oxalate crystals which are toxic if ingested.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'Keep out of reach of cats and dogs as it can cause mouth irritation and digestive upset.',
  ),
);
