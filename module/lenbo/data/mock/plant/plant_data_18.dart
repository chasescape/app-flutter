import '../../../../gen_a/A.dart';
import '../../models/plant_analysis.dart';

final plantData18 = PlantAnalysis(
  assetImg: A.assets_lenbo_18,
  plantId: PlantId(
    commonName: 'Cactus Collection',
    scientificName: 'Cactaceae family',
    family: 'Cactaceae',
    otherNames: ['Desert Plants', 'Spiny Succulents', 'Pilosocereus & Opuntia'],
    identificationConfidence: 0.98,
    funFact: 'Cacti have spines instead of leaves to minimize surface area, which prevents water loss through evaporation in harsh desert heat.',
  ),
  healthCheck: HealthCheck(
    status: 'Healthy',
    confidence: 0.95,
    visualEvidence: 'Firm, upright stems with vibrant blue and green coloration; no visible pests, soft spots, or discoloration.',
    symptoms: [],
    overallImpression: 'Your cacti collection looks absolutely thriving and perfectly placed in that sunny window!',
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
    expectedLifespan: '10-50+ years',
    maxHeight: 'Varies by species (6 inches to 3 feet indoors)',
  ),
  careGuide: CareGuide(
    summary: 'Low-maintenance desert dwellers that thrive on neglect and require maximum sunlight with minimal water.',
    watering: WateringGuide(
      frequency: 'Every 2-3 Weeks',
      method: 'Soak-and-drain: pour water until it flows out the drainage holes, then empty the saucer.',
      seasonalNote: 'In winter, reduce watering to once a month or less as the plants go dormant.',
    ),
    light: LightGuide(
      idealCondition: 'At least 6 hours of direct sun daily.',
      currentAssessment: 'Excellent placement; the direct sunlight through the window is ideal.',
      adjustmentTip: 'Rotate the pots 90 degrees every few weeks so they grow straight and don\'t lean toward the sun.',
    ),
    fertilizing: FertilizingGuide(
      schedule: 'Once a month during spring and summer.',
      recommendedType: 'Diluted cactus-specific liquid fertilizer.',
      seasonalNote: 'Stop all fertilizing in the fall and winter months.',
    ),
    temperature: TemperatureGuide(
      idealRange: '65°F - 85°F (18°C - 29°C)',
      tolerance: 'Can tolerate heat well but must be kept away from freezing drafts.',
    ),
    humidity: HumidityGuide(
      idealLevel: 'Low (10-30%)',
      boostMethods: ['Keep in a dry room', 'Ensure good air circulation', 'Avoid humid bathrooms'],
    ),
  ),
  commonIssues: [
    CommonIssue(
      problem: 'Root Rot',
      cause: 'Overwatering or poor drainage.',
      prevention: 'Use terracotta pots and well-draining sandy soil.',
      fix: 'Stop watering immediately and repot into fresh, dry cactus mix.',
    ),
    CommonIssue(
      problem: 'Etiolation (Stretching)',
      cause: 'Insufficient light causing the plant to reach for the sun.',
      prevention: 'Keep in the brightest window available.',
      fix: 'Move to a sunnier spot; note that the stretched growth is permanent.',
    ),
  ],
  proTip: 'Use a wooden chopstick to check the soil; if it comes out completely clean and dry to the bottom, it\'s time to water.',
  plantPersonality: 'These stoic sun-worshippers are the ultimate low-drama roommates, adding a touch of desert chic with very little effort.',
  safety: SafetyInfo(
    toxicityNote: 'While mostly non-toxic if ingested, the sharp spines pose a physical injury risk to pets and children.',
    petSafe: false,
    hasSensitiveContent: false,
    notes: 'The spines can cause skin irritation and are difficult to remove from fur or skin.',
  ),
);
