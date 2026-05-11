import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData9 = PlantAnalysis(
  assetImg: A.assets_lenbo_9,
  plantId: PlantId(
    commonName: 'Moth Orchid',
    scientificName: 'Phalaenopsis',
    family: 'Orchidaceae',
    otherNames: ['Phals', 'Butterfly Orchid'],
    identificationConfidence: 0.98,
    funFact: 'In the wild, these orchids are epiphytes, meaning they grow on trees and use their silver-green roots to cling to bark and breathe.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Vibrant, upright flower spikes with numerous open blooms and firm, glossy green leaves at the base.',
    symptoms: [],
    overallImpression: 'These orchids are in peak flowering condition and appear exceptionally well-cared for in this bright environment.',
  ),
  environmentReading: EnvironmentReading(
    lightEnv: 'Bright Indirect',
    soilMoistureVisual: 'Moist',
    potTypeGuess: 'Potted',
    indoorOrOutdoor: 'Indoor',
  ),
  growthInfo: GrowthInfo(
    stage: 'Flowering',
    difficultyLevel: 'Moderate',
    expectedLifespan: '10-15+ years',
    maxHeight: '24-36 inches',
  ),
  careGuide: CareGuide(
    summary: 'Moth orchids are elegant, long-blooming plants that thrive on consistency, filtered light, and high humidity.',
    watering: WateringGuide(
      frequency: 'Once a Week',
      method: 'Soak-and-drain: Submerge the inner pot in water for 15 minutes, then drain completely to avoid standing water.',
      seasonalNote: 'Water less frequently in winter when growth slows down and evaporation is lower.',
    ),
    light: LightGuide(
      idealCondition: 'Bright, filtered light, similar to an east-facing window.',
      currentAssessment: 'The greenhouse setting provides the perfect diffused light for these blooms.',
      adjustmentTip: 'If leaves turn dark green, they need more light; if they develop yellow or bleached spots, they are getting too much sun.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Every two weeks during growth and flowering.',
      recommendedType: 'Balanced liquid fertilizer diluted to half-strength.',
      seasonalNote: 'Reduce to once a month during the dormant period after the flowers have fallen.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F',
      tolerance: 'Avoid cold drafts and temperatures below 60°F.',
    ),
    humidity: HumidityGuide(
      idealLevel: '50-70%',
      boostMethods: ['Use a pebble tray with water', 'Group with other plants', 'Use a room humidifier'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or lack of airflow around roots.',
      prevention: 'Use a chunky bark-based potting mix and never let the plant sit in water.',
      fix: 'Trim mushy, black roots and repot in fresh, dry orchid bark.',
    ),
    CommonIssue(
      problem: 'Bud Blast',
      cause: 'Sudden temperature drops or low humidity.',
      prevention: 'Keep away from AC vents, heaters, or drafty windows.',
      fix: 'Stabilize the environment and increase humidity to protect remaining buds.',
    ),
  ],
  proTip: 'When the last flower falls, cut the stem just above the second \'node\' (the small bump) from the base to encourage a second flush of blooms.',
  plantPersonality: 'The Moth Orchid is the \'Elegant Diva\' of the houseplant world—she demands a specific routine but rewards your devotion with months of stunning, graceful flowers.',
  safety: SafetyInfo(
    toxicityNote: 'No known toxicity concerns for cats or dogs.',
    petSafe: true,
    hasSensitiveContent: false,
    notes: 'A perfectly safe choice for households with curious pets.',
  ),
);
