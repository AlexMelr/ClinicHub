class Patient {
  final int id;
  final String name;
  final int? age;
  final String? gender;
  final String? phone;
  final bool enabled;
  final String createdAt;

  Patient({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.phone,
    required this.enabled,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    gender: json['gender'],
    phone: json['phone'],
    enabled: json['enabled'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'phone': phone,
  };
}
