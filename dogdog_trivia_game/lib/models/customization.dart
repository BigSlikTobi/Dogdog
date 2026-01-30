/// Model for companion customization items (accessories, decorations)
enum AccessoryType {
  hat,
  collar,
  bandana,
  glasses,
  bow,
  toy,
}

enum DecorationCategory {
  furniture,
  wallArt,
  plants,
  rugs,
  lighting,
  outdoor,
}

/// An accessory item for the companion
class Accessory {
  final String id;
  final String name;
  final String emoji;
  final AccessoryType type;
  final int bondRequired;
  final bool isUnlocked;
  final bool isEquipped;

  const Accessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.bondRequired,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  Accessory unlock() => Accessory(
    id: id,
    name: name,
    emoji: emoji,
    type: type,
    bondRequired: bondRequired,
    isUnlocked: true,
    isEquipped: isEquipped,
  );

  Accessory equip() => Accessory(
    id: id,
    name: name,
    emoji: emoji,
    type: type,
    bondRequired: bondRequired,
    isUnlocked: isUnlocked,
    isEquipped: true,
  );

  Accessory unequip() => Accessory(
    id: id,
    name: name,
    emoji: emoji,
    type: type,
    bondRequired: bondRequired,
    isUnlocked: isUnlocked,
    isEquipped: false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'type': type.name,
    'bondRequired': bondRequired,
    'isUnlocked': isUnlocked,
    'isEquipped': isEquipped,
  };

  factory Accessory.fromJson(Map<String, dynamic> json) => Accessory(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    type: AccessoryType.values.firstWhere((t) => t.name == json['type']),
    bondRequired: json['bondRequired'] as int,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isEquipped: json['isEquipped'] as bool? ?? false,
  );
}

/// A home decoration item
class HomeDecoration {
  final String id;
  final String name;
  final String emoji;
  final DecorationCategory category;
  final int bondRequired;
  final bool isUnlocked;
  final bool isPlaced;

  const HomeDecoration({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.bondRequired,
    this.isUnlocked = false,
    this.isPlaced = false,
  });

  HomeDecoration unlock() => HomeDecoration(
    id: id,
    name: name,
    emoji: emoji,
    category: category,
    bondRequired: bondRequired,
    isUnlocked: true,
    isPlaced: isPlaced,
  );

  HomeDecoration togglePlacement() => HomeDecoration(
    id: id,
    name: name,
    emoji: emoji,
    category: category,
    bondRequired: bondRequired,
    isUnlocked: isUnlocked,
    isPlaced: !isPlaced,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'category': category.name,
    'bondRequired': bondRequired,
    'isUnlocked': isUnlocked,
    'isPlaced': isPlaced,
  };

  factory HomeDecoration.fromJson(Map<String, dynamic> json) => HomeDecoration(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    category: DecorationCategory.values.firstWhere(
      (c) => c.name == json['category'],
    ),
    bondRequired: json['bondRequired'] as int,
    isUnlocked: json['isUnlocked'] as bool? ?? false,
    isPlaced: json['isPlaced'] as bool? ?? false,
  );
}

/// Default accessories available in the game
class DefaultAccessories {
  static const List<Accessory> all = [
    // Hats
    Accessory(id: 'party_hat', name: 'Party Hat', emoji: '🎉', type: AccessoryType.hat, bondRequired: 0),
    Accessory(id: 'crown', name: 'Royal Crown', emoji: '👑', type: AccessoryType.hat, bondRequired: 25),
    Accessory(id: 'wizard_hat', name: 'Wizard Hat', emoji: '🧙', type: AccessoryType.hat, bondRequired: 50),
    Accessory(id: 'cap', name: 'Cool Cap', emoji: '🧢', type: AccessoryType.hat, bondRequired: 75),
    
    // Collars
    Accessory(id: 'red_collar', name: 'Red Collar', emoji: '🔴', type: AccessoryType.collar, bondRequired: 0),
    Accessory(id: 'gold_collar', name: 'Golden Collar', emoji: '🥇', type: AccessoryType.collar, bondRequired: 30),
    Accessory(id: 'gem_collar', name: 'Gem Collar', emoji: '💎', type: AccessoryType.collar, bondRequired: 60),
    
    // Bandanas
    Accessory(id: 'red_bandana', name: 'Red Bandana', emoji: '🟥', type: AccessoryType.bandana, bondRequired: 10),
    Accessory(id: 'blue_bandana', name: 'Blue Bandana', emoji: '🟦', type: AccessoryType.bandana, bondRequired: 20),
    Accessory(id: 'rainbow', name: 'Rainbow Scarf', emoji: '🌈', type: AccessoryType.bandana, bondRequired: 80),
    
    // Glasses
    Accessory(id: 'sunglasses', name: 'Cool Shades', emoji: '😎', type: AccessoryType.glasses, bondRequired: 15),
    Accessory(id: 'nerd_glasses', name: 'Nerd Glasses', emoji: '🤓', type: AccessoryType.glasses, bondRequired: 35),
    
    // Bows
    Accessory(id: 'pink_bow', name: 'Pink Bow', emoji: '🎀', type: AccessoryType.bow, bondRequired: 5),
    Accessory(id: 'bowtie', name: 'Fancy Bowtie', emoji: '🎩', type: AccessoryType.bow, bondRequired: 40),
    
    // Toys
    Accessory(id: 'ball', name: 'Red Ball', emoji: '🔴', type: AccessoryType.toy, bondRequired: 0),
    Accessory(id: 'frisbee', name: 'Frisbee', emoji: '🥏', type: AccessoryType.toy, bondRequired: 20),
    Accessory(id: 'bone', name: 'Chew Bone', emoji: '🦴', type: AccessoryType.toy, bondRequired: 10),
  ];
}

/// Default decorations available in the game
class DefaultDecorations {
  static const List<HomeDecoration> all = [
    // Furniture
    HomeDecoration(id: 'dog_bed', name: 'Cozy Dog Bed', emoji: '🛏️', category: DecorationCategory.furniture, bondRequired: 0),
    HomeDecoration(id: 'cushion', name: 'Fluffy Cushion', emoji: '🛋️', category: DecorationCategory.furniture, bondRequired: 15),
    HomeDecoration(id: 'castle', name: 'Dog Castle', emoji: '🏰', category: DecorationCategory.furniture, bondRequired: 70),
    
    // Wall Art
    HomeDecoration(id: 'paw_print', name: 'Paw Print Art', emoji: '🐾', category: DecorationCategory.wallArt, bondRequired: 10),
    HomeDecoration(id: 'photo', name: 'Family Photo', emoji: '🖼️', category: DecorationCategory.wallArt, bondRequired: 25),
    HomeDecoration(id: 'clock', name: 'Bone Clock', emoji: '🕐', category: DecorationCategory.wallArt, bondRequired: 40),
    
    // Plants
    HomeDecoration(id: 'flower', name: 'Sunflower', emoji: '🌻', category: DecorationCategory.plants, bondRequired: 5),
    HomeDecoration(id: 'cactus', name: 'Mini Cactus', emoji: '🌵', category: DecorationCategory.plants, bondRequired: 20),
    HomeDecoration(id: 'tree', name: 'Bonsai Tree', emoji: '🌳', category: DecorationCategory.plants, bondRequired: 50),
    
    // Rugs
    HomeDecoration(id: 'round_rug', name: 'Round Rug', emoji: '⭕', category: DecorationCategory.rugs, bondRequired: 15),
    HomeDecoration(id: 'star_rug', name: 'Star Rug', emoji: '⭐', category: DecorationCategory.rugs, bondRequired: 35),
    
    // Lighting
    HomeDecoration(id: 'lamp', name: 'Cozy Lamp', emoji: '💡', category: DecorationCategory.lighting, bondRequired: 10),
    HomeDecoration(id: 'fairy_lights', name: 'Fairy Lights', emoji: '✨', category: DecorationCategory.lighting, bondRequired: 30),
    
    // Outdoor
    HomeDecoration(id: 'birdbath', name: 'Bird Bath', emoji: '🐦', category: DecorationCategory.outdoor, bondRequired: 45),
    HomeDecoration(id: 'fountain', name: 'Water Fountain', emoji: '⛲', category: DecorationCategory.outdoor, bondRequired: 65),
  ];
}
