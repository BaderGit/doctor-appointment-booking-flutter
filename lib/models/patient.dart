// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PatientModel {
  String? id;
  final String imgUrl;
  final String name;
  final String age;
  final String gender;
  final String email;

  PatientModel({
    this.id,
    required this.imgUrl,
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'imgUrl': imgUrl,
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
    };
  }

  factory PatientModel.fromMap(Map<String, dynamic> map) {
    return PatientModel(
      id: map['id'] != null ? map['id'] as String : null,
      imgUrl: map['imgUrl'] as String,
      name: map['name'] as String,
      age: map['age'] as String,
      gender: map['gender'] as String,
      email: map['email'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PatientModel.fromJson(String source) =>
      PatientModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
