import 'package:final_project/data/sp_helper.dart';
import 'package:final_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// Provider class for managing language and localization in the app
class LanguageProvider extends ChangeNotifier {
  // Current locale setting (defaults to English)
  Locale currentLocale = Locale("en");

  // Flag to track if Arabic is currently selected
  bool isArabic = false;

  // Constructor - initializes by getting the current locale
  LanguageProvider() {
    getCurrentLocale();
  }

  // Gets the current locale from shared preferences
  getCurrentLocale() async {
    currentLocale = Locale(await SpHelper.spHelper.getLanguage() ?? "en");
    notifyListeners();
  }

  // Toggles between English and Arabic languages
  void toggleLanguage() async {
    // Flip the Arabic flag
    isArabic = isArabic ? false : true;

    // Switch between English and Arabic locales
    currentLocale = currentLocale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');

    // Save the new language preference
    await SpHelper.spHelper.setLanguage(currentLocale.toString());
    notifyListeners();
  }

  // Returns the localized string for medical specialities
  String getSpecialityLocalization(
    String specialityKey,
    AppLocalizations localization,
  ) {
    switch (specialityKey.toLowerCase()) {
      case 'general':
        return localization.general;
      case 'cardiology':
        return localization.cardiology;
      case 'respirations':
        return localization.respirations;
      case 'dermatology':
        return localization.dermatology;
      case 'gynecology':
        return localization.gynecology;
      case 'dental':
        return localization.dental;

      default:
        return specialityKey;
    }
  }

  // Returns the localized string for hospital names
  String getHospitalNameLocalization(
    String hospital,
    AppLocalizations localization,
  ) {
    switch (hospital.toLowerCase()) {
      case 'sarawak general hospital':
        return localization.hospitalName1;
      case 'royal cardiac center':
        return localization.hospitalName2;
      case 'nova care hospital':
        return localization.hospitalName3;
      case 'harmony general hospital':
        return localization.hospitalName4;
      case 'apex medical hub':
        return localization.hospitalName5;
      case 'zenith health campus':
        return localization.hospitalName6;

      default:
        return hospital;
    }
  }

  // Returns the localized string for gender
  String getGenderLocalization(String gender, AppLocalizations localization) {
    switch (gender.toLowerCase()) {
      case 'male':
        return localization.male;
      case 'female':
        return localization.female;

      default:
        return gender;
    }
  }

  // Returns the localized string for appointment times
  String getTimeLocalization(String time, AppLocalizations localization) {
    switch (time.toLowerCase()) {
      case '9:00 am':
        return localization.time_9am;
      case '10:00 am':
        return localization.time_10am;
      case '11:00 am':
        return localization.time_11am;
      case '12:00 pm':
        return localization.time_12pm;
      case '13:00 pm':
        return localization.time_1pm;
      case '14:00 pm':
        return localization.time_2pm;
      case '15:00 pm':
        return localization.time_3pm;
      case '16:00 pm':
        return localization.time_4pm;

      default:
        return time;
    }
  }

  // Returns the localized string for days of the week
  String getDayLocalization(String day, AppLocalizations localization) {
    switch (day.toLowerCase()) {
      case 'monday':
        return localization.monday;
      case 'tuesday':
        return localization.tuesday;
      case 'wednesday':
        return localization.wednesday;
      case 'thursday':
        return localization.thursday;
      case 'friday':
        return localization.friday;
      case 'saturday':
        return localization.saturday;
      case 'sunday':
        return localization.sunday;

      default:
        return day;
    }
  }
}
