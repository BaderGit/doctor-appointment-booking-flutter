import 'package:shared_preferences/shared_preferences.dart';

// SpHelper - A helper class for managing SharedPreferences (local storage)
class SpHelper {
  SpHelper._();

  static final SpHelper spHelper = SpHelper._();

  SharedPreferences? prefs;

  // Stores the user type ('staff', 'doctor', 'patient') in SharedPreferences
  Future<void> setUserType(String userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userType', userType);
  }

  // Stores the staff password in SharedPreferences
  Future<void> setStaffPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedPassword', password);
  }

  // Stores the staff email in SharedPreferences
  Future<void> setStaffEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('staffEmail', email);
  }

  // Stores the doctor password in SharedPreferences
  Future<void> setDoctorPassword(String password) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('doctorPassword', password);
  }

  // Stores the app language setting in SharedPreferences
  Future<void> setLanguage(String locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('currentLocale', locale);
  }

  // Retrieves the stored user type from SharedPreferences
  Future<String?> getUserType() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? userType;
    userType = pref.getString('userType');
    return userType;
  }

  // Retrieves the stored staff password from SharedPreferences
  Future<String?> getStaffPassword() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? password;
    password = pref.getString('storedPassword');
    return password;
  }

  // Retrieves the stored staff email from SharedPreferences
  Future<String?> getStaffEmail() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? email;
    email = pref.getString('staffEmail');
    return email;
  }

  // Retrieves the stored doctor password from SharedPreferences
  Future<String?> getDoctorPassword() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? password;
    password = pref.getString('doctorPassword');
    return password;
  }

  // Retrieves the stored language/locale setting from SharedPreferences
  Future<String?> getLanguage() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? currentLocale;
    currentLocale = pref.getString('currentLocale');

    return currentLocale;
  }
}
