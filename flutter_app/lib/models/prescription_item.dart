import 'herb.dart';

class PrescriptionItem {
  final int id;
  final Herb herb;
  final int doseG;
  final String? note;

  PrescriptionItem({
    required this.id,
    required this.herb,
    required this.doseG,
    this.note,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) => PrescriptionItem(
    id: json['id'],
    herb: Herb.fromJson(json['herb']),
    doseG: json['doseG'],
    note: json['note'],
  );
}
