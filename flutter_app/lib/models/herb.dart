class Herb {
  final int id;
  final String name;
  final String? aliasName;
  final String? pinyin;
  final int stockG;
  final String unit;
  final int warnThresholdG;
  final bool enabled;
  final String createdAt;

  Herb({
    required this.id,
    required this.name,
    this.aliasName,
    this.pinyin,
    required this.stockG,
    required this.unit,
    required this.warnThresholdG,
    required this.enabled,
    required this.createdAt,
  });

  factory Herb.fromJson(Map<String, dynamic> json) => Herb(
    id: json['id'],
    name: json['name'],
    aliasName: json['aliasName'],
    pinyin: json['pinyin'],
    stockG: json['stockG'],
    unit: json['unit'],
    warnThresholdG: json['warnThresholdG'],
    enabled: json['enabled'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'aliasName': aliasName,
    'pinyin': pinyin,
    'stockG': stockG,
    'unit': unit,
    'warnThresholdG': warnThresholdG,
  };

  bool get isLowStock => stockG <= warnThresholdG;
}
