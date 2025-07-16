import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:final_project/data/auth_helper.dart';
import 'package:final_project/data/firestore_helper.dart';
import 'package:final_project/data/sp_helper.dart';

import 'package:final_project/data/storage_helper.dart';
import 'package:final_project/l10n/app_localizations.dart';
import 'package:final_project/main_layout.dart';
import 'package:final_project/models/patient.dart';
import 'package:final_project/models/doctor.dart';

import 'package:final_project/utils/app_router.dart';
import 'package:final_project/utils/custom_dialog.dart';

import 'package:final_project/views/screens/staff/staff_screen.dart';
import 'package:final_project/views/screens/auth/user_type_screen.dart';

// import 'package:final_project/utils/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:string_validator/string_validator.dart';

class AppAuthProvider extends ChangeNotifier {
  String? userType;
  GlobalKey<FormState> loginKey = GlobalKey();
  GlobalKey<FormState> signUpKey = GlobalKey();
  GlobalKey<FormState> forgetPassUpKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String selectedGender = "male";

  TextEditingController doctorEmailController = TextEditingController();
  TextEditingController doctorPasswordController = TextEditingController();
  TextEditingController doctorUserNameController = TextEditingController();

  TextEditingController forgetPasswordEmailController = TextEditingController();
  String? selectedSpeciality;
  String? selectedHospital;

  File? selectedPatientImage;
  File? selectedDoctorImage;
  bool isLoading = false;

  nullValidation(String? value, AppLocalizations localization) {
    if (value == null || value.isEmpty) {
      return localization.nullValidation;
    }
  }

  emailValidation(String? value, AppLocalizations localization) {
    nullValidation(value, localization);
    if (!isEmail(value!)) {
      return localization.emailValidation;
    }
  }

  passwordValidation(String? value, AppLocalizations localization) {
    nullValidation(value, localization);
    if (value!.length < 6) {
      return localization.passwordValidation;
    }
  }

  Future<UserCredential?> signIn(AppLocalizations localization) async {
    try {
      if (loginKey.currentState!.validate()) {
        isLoading = true;
        notifyListeners();
        if (userType == "doctor") {
          UserCredential? doctorCredentials = await AuthHelper.authHelper
              .signIn(
                doctorEmailController.text,
                doctorPasswordController.text,
                localization,
              );

          if (doctorCredentials != null) {
            final doctor = await FireStoreHelper.fireStoreHelper
                .getDoctorFromFireStore(doctorCredentials.user!.uid);
            if (doctor != null) {
              isLoading = false;
              notifyListeners();
              AppRouter.navigateToWidgetWithReplacment(MainLayout());

              return doctorCredentials;
            }
            AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());

            CustomShowDialog.showDialogFunction(
              localization.rightUserTypeValidation,
              localization,
            );

            isLoading = false;
            notifyListeners();

            return null;
          }
        } else {
          UserCredential? credentials = await AuthHelper.authHelper.signIn(
            emailController.text,
            passwordController.text,
            localization,
          );
          SpHelper.spHelper.setStaffPassword(passwordController.text);
          SpHelper.spHelper.setStaffEmail(emailController.text);

          if (credentials != null) {
            if (userType == "patient") {
              final patient = await FireStoreHelper.fireStoreHelper
                  .getPatientFromFireStore(credentials.user!.uid);

              if (patient != null) {
                AppRouter.navigateToWidgetWithReplacment(MainLayout());
                return credentials;
              } else {
                AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());

                CustomShowDialog.showDialogFunction(
                  localization.rightUserTypeValidation,
                  localization,
                );
              }
            } else if (userType == "staff") {
              final staff = await FireStoreHelper.fireStoreHelper
                  .getStaffFromFireStore(credentials.user!.uid);

              if (staff) {
                AppRouter.navigateToWidgetWithReplacment(StaffScreen());
              } else {
                AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());

                CustomShowDialog.showDialogFunction(
                  localization.rightUserTypeValidation,
                  localization,
                );
                return null;
              }
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      emailController.clear();
      passwordController.clear();
      doctorEmailController.clear();
      doctorPasswordController.clear();
    }

    return null;
  }

  checkUser(String? userType) async {
    User? user;
    user = await AuthHelper.authHelper.checkUser();

    if (user == null) {
      AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
    } else if (userType == "patient") {
      final patient = await FireStoreHelper.fireStoreHelper
          .getPatientFromFireStore(user.uid);
      if (patient == null) {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(MainLayout());
      }
    } else if (userType == "staff") {
      final staff = await FireStoreHelper.fireStoreHelper.getStaffFromFireStore(
        user.uid,
      );

      if (staff) {
        AppRouter.navigateToWidgetWithReplacment(StaffScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      }
    } else if (userType == "doctor") {
      final doctor = await FireStoreHelper.fireStoreHelper
          .getDoctorFromFireStore(user.uid);
      if (doctor == null) {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(MainLayout());
      }
    }
  }

  signOut() async {
    await AuthHelper.authHelper.signOut();
    AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
    // SpHelper.spHelper.setUserType("");
    emailController.clear();
    passwordController.clear();
    ageController.clear();
    doctorUserNameController.clear();
    forgetPasswordEmailController.clear();
    doctorEmailController.clear();
    doctorPasswordController.clear();
    selectedGender = "male";
    selectedSpeciality = null;
    selectedHospital = null;
    selectedPatientImage = null;
    selectedDoctorImage = null;
  }

  Future<UserCredential?> userSignUp(AppLocalizations localization) async {
    try {
      isLoading = true;
      notifyListeners();
      if (selectedPatientImage == null) {
        CustomShowDialog.showDialogFunction(
          localization.pictureValidation,
          localization,
        );
        isLoading = false;
        notifyListeners();
        return null;
      }
      if (signUpKey.currentState!.validate()) {
        UserCredential? credentials = await AuthHelper.authHelper.signUp(
          emailController.text,
          passwordController.text,
          localization,
        );

        if (credentials != null) {
          String? imageUrl = await StorageHelper.storageHelper.uploadImage(
            selectedPatientImage!,
          );
          PatientModel patient = PatientModel(
            id: credentials.user!.uid,
            email: emailController.text,
            name: userNameController.text,
            age: ageController.text,
            gender: selectedGender,
            imgUrl: imageUrl ?? "",
          );

          await FireStoreHelper.fireStoreHelper.addUserToFireStore(patient);

          AppRouter.navigateToWidgetWithReplacment(MainLayout());
          emailController.clear();
          userNameController.clear();
          ageController.clear();

          passwordController.clear();
          selectedPatientImage = null;

          return credentials;
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return null;
  }

  Future<UserCredential?> doctorSignUp(AppLocalizations localization) async {
    try {
      String? storedStaffPassword;

      isLoading = true;
      notifyListeners();
      if (selectedDoctorImage == null) {
        CustomShowDialog.showDialogFunction(
          localization.pictureValidation,
          localization,
        );
        isLoading = false;
        notifyListeners();
        return null;
      }
      if (signUpKey.currentState!.validate()) {
        User? currentUser = AuthHelper.authHelper.firebaseAuth.currentUser;
        String? currentUserEmail =
            AuthHelper.authHelper.firebaseAuth.currentUser?.email;

        UserCredential? credentials = await AuthHelper.authHelper.signUp(
          doctorEmailController.text,
          doctorPasswordController.text,
          localization,
        );
        SpHelper.spHelper.setDoctorPassword(doctorPasswordController.text);
        if (credentials != null) {
          String? doctorImageUrl = await StorageHelper.storageHelper
              .uploadImage(selectedDoctorImage!);
          Random random = Random();
          DoctorModel doctor = DoctorModel(
            id: credentials.user!.uid,
            email: doctorEmailController.text,
            name: doctorUserNameController.text,
            speciality: selectedSpeciality!,
            hospitalName: selectedHospital!,
            imgUrl: doctorImageUrl ?? "",
            patientNumbers: (20 + random.nextInt(31)).toString(),
            experience: (3 + random.nextInt(8)).toString(),
            rating: ((random.nextInt(6) + 45) / 10).toString(),
          );
          await FireStoreHelper.fireStoreHelper.addDoctorToFireStore(doctor);

          CustomShowDialog.showDialogFunction(
            localization.doctorAddSuccess,
            localization,
          );
          isLoading = false;
          doctorEmailController.clear();
          doctorUserNameController.clear();
          selectedSpeciality = null;
          selectedHospital = null;
          selectedDoctorImage = null;
          doctorPasswordController.clear();

          notifyListeners();
          if (currentUser != null && currentUserEmail != null) {
            storedStaffPassword = await SpHelper.spHelper.getStaffPassword();
            await AuthHelper.authHelper.signIn(
              currentUserEmail,
              storedStaffPassword ?? "",
              localization,
            );
          }
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
    return null;
  }
  // deleteDoctorAccount(){

  // }
  forgetPassword(AppLocalizations localization) async {
    if (forgetPassUpKey.currentState!.validate()) {
      isLoading = true;
      notifyListeners();
      await AuthHelper.authHelper.forgetPassword(
        forgetPasswordEmailController.text,
        localization,
      );

      forgetPasswordEmailController.clear();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (userType == "patient") {
        selectedPatientImage = File(pickedFile.path);
        notifyListeners();
      } else {
        selectedDoctorImage = File(pickedFile.path);
        notifyListeners();
      }
    }
  }
}
