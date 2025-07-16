import 'package:shared_preferences/shared_preferences.dart';

class SpHelper {
  SpHelper._();

  static final SpHelper spHelper = SpHelper._();
  SharedPreferences? prefs;

  Future<void> setUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userType', userType);
  }

  Future<void> setStaffPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedPassword', password);
  }

  Future<void> setStaffEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('staffEmail', email);
  }

  Future<void> setDoctorPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('doctorPassword', password);
  }

  Future<void> setLanguage(String locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentLocale', locale);
  }

  Future<String?> getUserType() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? userType;
    userType = pref.getString('userType');
    return userType;
  }

  Future<String?> getStaffPassword() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? password;
    password = pref.getString('storedPassword');
    return password;
  }

  Future<String?> getStaffEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? email;
    email = pref.getString('staffEmail');
    return email;
  }

  Future<String?> getDoctorPassword() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? password;
    password = pref.getString('doctorPassword');
    return password;
  }

  Future<String?> getLanguage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? currentLocale;
    currentLocale = pref.getString('currentLocale');

    return currentLocale;
  }
}
