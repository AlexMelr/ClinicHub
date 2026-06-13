import 'herb.dart';

class StockFlow {
  final int id;
  final Herb herb;
  final String flowType;
  final int qtyG;
  final int? remainG;
  final String? remark;
  final String createdAt;

  StockFlow({
    required this.id,
    required this.herb,
    required this.flowType,
    required this.qtyG,
    this.remainG,
    this.remark,
    required this.createdAt,
  });

  factory StockFlow.fromJson(Map<String, dynamic> json) => StockFlow(
    id: json['id'],
    herb: Herb.fromJson(json['herb']),
    flowType: json['flowType'],
    qtyG: json['qtyG'],
    remainG: json['remainG'],
    remark: json['remark'],
    createdAt: json['createdAt'],
  );

  bool get isIn => flowType == 'IN';
}
