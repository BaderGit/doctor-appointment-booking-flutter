import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first

class DoctorModel {
  String? id;

  final String name;
  final String email;
  final String speciality;
  final String hospitalName;
  final String imgUrl;
  final String patientNumbers;
  final String experience;
  final String rating;

  DoctorModel({
    this.id,
    required this.name,
    required this.email,
    required this.speciality,
    required this.hospitalName,
    required this.imgUrl,
    required this.patientNumbers,
    required this.experience,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'speciality': speciality,
      'hospitalName': hospitalName,
      'imgUrl': imgUrl,
      'patientNumbers': patientNumbers,
      'experience': experience,
      'rating': rating,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'] != null ? map['id'] as String : null,
      name: map['name'] as String,
      email: map['email'] as String,
      speciality: map['speciality'] as String,
      hospitalName: map['hospitalName'] as String,
      imgUrl: map['imgUrl'] as String,
      patientNumbers: map['patientNumbers'] as String,
      experience: map['experience'] as String,
      rating: map['rating'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DoctorModel.fromJson(String source) =>
      DoctorModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
