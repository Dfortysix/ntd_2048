class FruitTile {
  final int value;
  final String emoji;
  final String name;
  final String description;

  const FruitTile({
    required this.value,
    required this.emoji,
    required this.name,
    required this.description,
  });

  static const Map<int, FruitTile> fruits = {
    2: FruitTile(
      value: 2,
      emoji: '🍒',
      name: 'Cherry',
      description: 'Trái nhỏ, đỏ',
    ),
    4: FruitTile(
      value: 4,
      emoji: '🍓',
      name: 'Dâu tây',
      description: 'Mọng nước, đỏ tươi',
    ),
    8: FruitTile(
      value: 8,
      emoji: '🍇',
      name: 'Nho',
      description: 'Chùm trái tím',
    ),
    16: FruitTile(
      value: 16,
      emoji: '🍊',
      name: 'Quýt',
      description: 'Vỏ cam, mọng nước',
    ),
    32: FruitTile(
      value: 32,
      emoji: '🍎',
      name: 'Táo',
      description: 'Đỏ bóng, giòn',
    ),
    64: FruitTile(
      value: 64,
      emoji: '🍐',
      name: 'Lê',
      description: 'Vàng nhạt, ngọt',
    ),
    128: FruitTile(
      value: 128,
      emoji: '🍑',
      name: 'Đào',
      description: 'Hồng cam, thơm',
    ),
    256: FruitTile(
      value: 256,
      emoji: '🥭',
      name: 'Xoài',
      description: 'Vàng óng, mềm',
    ),
    512: FruitTile(
      value: 512,
      emoji: '🍍',
      name: 'Dứa',
      description: 'Vỏ xù xì, lá xanh',
    ),
    1024: FruitTile(
      value: 1024,
      emoji: '🍉',
      name: 'Dưa hấu',
      description: 'Vỏ xanh, ruột đỏ',
    ),
    2048: FruitTile(
      value: 2048,
      emoji: '🍈',
      name: 'Dưa gang',
      description: 'Vỏ sọc, ruột trắng',
    ),
    4096: FruitTile(
      value: 4096,
      emoji: '🥥',
      name: 'Dừa',
      description: 'Vỏ cứng, nước ngọt',
    ),
    8192: FruitTile(
      value: 8192,
      emoji: '🧺',
      name: 'Giỏ thần kỳ',
      description: 'Giỏ phép thuật ✨',
    ),
  };

  static FruitTile? getFruit(int value) {
    return fruits[value];
  }

  static String getDisplayText(int value) {
    final fruit = getFruit(value);
    if (fruit != null) {
      return fruit.emoji;
    }
    return '$value';
  }

  static String getFruitName(int value) {
    final fruit = getFruit(value);
    return fruit?.name ?? 'Unknown';
  }
} 