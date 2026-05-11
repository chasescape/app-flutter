import 'package:velise/gen_a/a.dart';

class ThingTaleItem {
  String assetImg;
  SceneCard sceneCard;
  PrimaryItem primaryItem;
  Description description;
  List<String> tags;
  MemoryReflection memoryReflection;
  Discovery discovery;

  ThingTaleItem({
    required this.assetImg,
    required this.sceneCard,
    required this.primaryItem,
    required this.description,
    required this.tags,
    required this.memoryReflection,
    required this.discovery,
  });

  factory ThingTaleItem.fromJson(Map<String, dynamic> json) {
    return ThingTaleItem(
      assetImg: json['assetImg'] as String,
      sceneCard: SceneCard.fromJson(json['scene_card'] as Map<String, dynamic>),
      primaryItem: PrimaryItem.fromJson(json['primary_item'] as Map<String, dynamic>),
      description: Description.fromJson(json['description'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      memoryReflection: MemoryReflection.fromJson(json['memory_reflection'] as Map<String, dynamic>),
      discovery: Discovery.fromJson(json['discovery'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetImg': assetImg,
      'scene_card': sceneCard.toJson(),
      'primary_item': primaryItem.toJson(),
      'description': description.toJson(),
      'tags': tags,
      'memory_reflection': memoryReflection.toJson(),
      'discovery': discovery.toJson(),
    };
  }
}

class SceneCard {
  String location;
  String timeContext;
  String mood;
  String lighting;

  SceneCard({
    required this.location,
    required this.timeContext,
    required this.mood,
    required this.lighting,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      location: json['location'] as String,
      timeContext: json['time_context'] as String,
      mood: json['mood'] as String,
      lighting: json['lighting'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'time_context': timeContext,
      'mood': mood,
      'lighting': lighting,
    };
  }
}

class PrimaryItem {
  String category;
  String nameHint;
  int quantity;
  List<String> colors;
  List<String> materials;
  String style;
  String condition;
  String craftsmanshipNotes;

  PrimaryItem({
    required this.category,
    required this.nameHint,
    required this.quantity,
    required this.colors,
    required this.materials,
    required this.style,
    required this.condition,
    required this.craftsmanshipNotes,
  });

  factory PrimaryItem.fromJson(Map<String, dynamic> json) {
    return PrimaryItem(
      category: json['category'] as String,
      nameHint: json['name_hint'] as String,
      quantity: json['quantity'] as int,
      colors: (json['colors'] as List<dynamic>).cast<String>(),
      materials: (json['materials'] as List<dynamic>).cast<String>(),
      style: json['style'] as String,
      condition: json['condition'] as String,
      craftsmanshipNotes: json['craftsmanship_notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'name_hint': nameHint,
      'quantity': quantity,
      'colors': colors,
      'materials': materials,
      'style': style,
      'condition': condition,
      'craftsmanship_notes': craftsmanshipNotes,
    };
  }
}

class Description {
  String appearance;
  String character;
  String storyFeeling;

  Description({
    required this.appearance,
    required this.character,
    required this.storyFeeling,
  });

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      appearance: json['appearance'] as String,
      character: json['character'] as String,
      storyFeeling: json['story_feeling'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appearance': appearance,
      'character': character,
      'story_feeling': storyFeeling,
    };
  }
}

class MemoryReflection {
  String opening;
  String reflection;

  MemoryReflection({
    required this.opening,
    required this.reflection,
  });

  factory MemoryReflection.fromJson(Map<String, dynamic> json) {
    return MemoryReflection(
      opening: json['opening'] as String,
      reflection: json['reflection'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opening': opening,
      'reflection': reflection,
    };
  }
}

class Discovery {
  List<String> specialDetails;
  String possibleOrigin;
  List<String> companionItems;

  Discovery({
    required this.specialDetails,
    required this.possibleOrigin,
    required this.companionItems,
  });

  factory Discovery.fromJson(Map<String, dynamic> json) {
    return Discovery(
      specialDetails: (json['special_details'] as List<dynamic>).cast<String>(),
      possibleOrigin: json['possible_origin'] as String,
      companionItems: (json['companion_items'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'special_details': specialDetails,
      'possible_origin': possibleOrigin,
      'companion_items': companionItems,
    };
  }
}
