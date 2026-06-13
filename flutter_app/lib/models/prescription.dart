import 'prescription_item.dart';
import 'visit.dart';

class Prescription {
  final int id;
  final Visit visit;
  final int copies;
  final String? usageText;
  final String status;
  final String? remark;
  final String createdAt;
  final List<PrescriptionItem>? items;

  Prescription({
    required this.id,
    required this.visit,
    required this.copies,
    this.usageText,
    required this.status,
    this.remark,
    required this.createdAt,
    this.items,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    id: json['id'],
    visit: Visit.fromJson(json['visit']),
    copies: json['copies'],
    usageText: json['usageText'],
    status: json['status'],
    remark: json['remark'],
    createdAt: json['createdAt'],
    items: json['items'] != null
        ? (json['items'] as List).map((e) => PrescriptionItem.fromJson(e)).toList()
        : null,
  );
}
