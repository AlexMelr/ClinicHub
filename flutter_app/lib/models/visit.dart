import 'patient.dart';

class Visit {
  final int id;
  final Patient patient;
  final String visitTime;
  final String? chiefComplaint;
  final String? presentIllness;
  final String? pastHistory;
  final String? allergyHistory;
  final String? diagnosis;
  final String? advice;
  final String? doctorNote;
  final String createdAt;

  Visit({
    required this.id,
    required this.patient,
    required this.visitTime,
    this.chiefComplaint,
    this.presentIllness,
    this.pastHistory,
    this.allergyHistory,
    this.diagnosis,
    this.advice,
    this.doctorNote,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) => Visit(
    id: json['id'],
    patient: Patient.fromJson(json['patient']),
    visitTime: json['visitTime'],
    chiefComplaint: json['chiefComplaint'],
    presentIllness: json['presentIllness'],
    pastHistory: json['pastHistory'],
    allergyHistory: json['allergyHistory'],
    diagnosis: json['diagnosis'],
    advice: json['advice'],
    doctorNote: json['doctorNote'],
    createdAt: json['createdAt'],
  );
}
