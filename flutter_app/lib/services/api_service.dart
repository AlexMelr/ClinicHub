import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/herb.dart';
import '../models/patient.dart';
import '../models/visit.dart';
import '../models/prescription.dart';
import '../models/stock_flow.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8090/api';

  final http.Client _client = http.Client();

  dynamic _decode(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body);
  }

  // ===== Herb =====
  Future<List<Herb>> getHerbs({String? keyword, bool lowStock = false}) async {
    final params = <String, String>{};
    if (lowStock) {
      params['lowStock'] = 'true';
    } else if (keyword != null && keyword.isNotEmpty) {
      params['keyword'] = keyword;
    }
    final uri = Uri.parse('$baseUrl/herbs').replace(queryParameters: params.isEmpty ? null : params);
    final res = await _client.get(uri);
    final list = _decode(res) as List;
    return list.map((e) => Herb.fromJson(e)).toList();
  }

  Future<Herb> createHerb(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/herbs'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Herb.fromJson(_decode(res));
  }

  Future<Herb> updateHerb(int id, Map<String, dynamic> data) async {
    final res = await _client.put(
      Uri.parse('$baseUrl/herbs/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Herb.fromJson(_decode(res));
  }

  Future<void> deleteHerb(int id) async {
    final res = await _client.delete(Uri.parse('$baseUrl/herbs/$id'));
    _decode(res);
  }

  // ===== Patient =====
  Future<List<Patient>> getPatients({String? keyword}) async {
    final params = keyword != null && keyword.isNotEmpty ? {'keyword': keyword} : null;
    final res = await _client.get(Uri.parse('$baseUrl/patients').replace(queryParameters: params));
    final list = _decode(res) as List;
    return list.map((e) => Patient.fromJson(e)).toList();
  }

  Future<Patient> createPatient(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/patients'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Patient.fromJson(_decode(res));
  }

  Future<Patient> updatePatient(int id, Map<String, dynamic> data) async {
    final res = await _client.put(
      Uri.parse('$baseUrl/patients/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Patient.fromJson(_decode(res));
  }

  // ===== Visit =====
  Future<List<Visit>> getVisits({int? patientId}) async {
    final params = patientId != null ? {'patientId': '$patientId'} : null;
    final res = await _client.get(Uri.parse('$baseUrl/visits').replace(queryParameters: params));
    final list = _decode(res) as List;
    return list.map((e) => Visit.fromJson(e)).toList();
  }

  Future<Visit> createVisit(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/visits'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Visit.fromJson(_decode(res));
  }

  Future<Visit> updateVisit(int id, Map<String, dynamic> data) async {
    final res = await _client.put(
      Uri.parse('$baseUrl/visits/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Visit.fromJson(_decode(res));
  }

  // ===== Prescription =====
  Future<List<Prescription>> getPrescriptions({int? visitId}) async {
    final params = visitId != null ? {'visitId': '$visitId'} : null;
    final res = await _client.get(Uri.parse('$baseUrl/prescriptions').replace(queryParameters: params));
    final list = _decode(res) as List;
    return list.map((e) => Prescription.fromJson(e)).toList();
  }

  Future<Prescription> createPrescription(Map<String, dynamic> data) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/prescriptions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return Prescription.fromJson(_decode(res));
  }

  Future<Prescription> dispensePrescription(int id) async {
    final res = await _client.post(Uri.parse('$baseUrl/prescriptions/$id/dispense'));
    return Prescription.fromJson(_decode(res));
  }

  // ===== Stock =====
  Future<List<StockFlow>> getStockFlows({int? herbId}) async {
    final params = herbId != null ? {'herbId': '$herbId'} : null;
    final res = await _client.get(Uri.parse('$baseUrl/stock').replace(queryParameters: params));
    final list = _decode(res) as List;
    return list.map((e) => StockFlow.fromJson(e)).toList();
  }

  Future<StockFlow> stockIn(int herbId, int qtyG, String remark) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/stock/in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'herbId': herbId, 'qtyG': qtyG, 'remark': remark}),
    );
    return StockFlow.fromJson(_decode(res));
  }
}
