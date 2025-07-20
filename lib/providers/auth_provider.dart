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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:string_validator/string_validator.dart';

class AppAuthProvider extends ChangeNotifier {
  // Current user type (patient, staff, doctor)
  String? userType;

  // Form keys for validation
  GlobalKey<FormState> loginKey = GlobalKey();
  GlobalKey<FormState> signUpKey = GlobalKey();
  GlobalKey<FormState> forgetPassUpKey = GlobalKey();

  // Controllers for patient and staff form fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  String selectedGender = "male"; // Default gender selection

  // Controllers for doctor form fields
  TextEditingController doctorEmailController = TextEditingController();
  TextEditingController doctorPasswordController = TextEditingController();
  TextEditingController doctorUserNameController = TextEditingController();

  // Controller for forget password field
  TextEditingController forgetPasswordEmailController = TextEditingController();

  // Doctor-specific fields
  String? selectedSpeciality;
  String? selectedHospital;

  // Image files for patient and doctor profiles
  File? selectedPatientImage;
  File? selectedDoctorImage;

  // Loading state indicator
  bool isLoading = false;

  // Validation function for required fields
  nullValidation(String? value, AppLocalizations localization) {
    if (value == null || value.isEmpty) {
      return localization.nullValidation;
    }
  }

  // Email validation function
  emailValidation(String? value, AppLocalizations localization) {
    nullValidation(value, localization);
    if (!isEmail(value!)) {
      return localization.emailValidation;
    }
  }

  // Password validation function (minimum 6 characters)
  passwordValidation(String? value, AppLocalizations localization) {
    nullValidation(value, localization);
    if (value!.length < 6) {
      return localization.passwordValidation;
    }
  }

  // Sign in method for all user types
  Future<UserCredential?> signIn(AppLocalizations localization) async {
    try {
      if (loginKey.currentState!.validate()) {
        isLoading = true;
        notifyListeners();

        // Doctor-specific sign in flow
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
            // Handle incorrect user type
            AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
            CustomShowDialog.showDialogFunction(
              localization.rightUserTypeValidation,
              localization,
            );
            isLoading = false;
            notifyListeners();
            return null;
          }
        }
        // Patient and staff sign in flow
        else {
          UserCredential? credentials = await AuthHelper.authHelper.signIn(
            emailController.text,
            passwordController.text,
            localization,
          );
          // Store staff credentials in shared preferences
          SpHelper.spHelper.setStaffPassword(passwordController.text);
          SpHelper.spHelper.setStaffEmail(emailController.text);

          if (credentials != null) {
            // Patient flow
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
            }
            // Staff flow
            else if (userType == "staff") {
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
      // Reset loading state and clear controllers
      isLoading = false;
      emailController.clear();
      passwordController.clear();
      doctorEmailController.clear();
      doctorPasswordController.clear();
    }
    return null;
  }

  // Check current user status and navigate accordingly
  checkUser(String? userType) async {
    User? user;
    user = await AuthHelper.authHelper.checkUser();

    if (user == null) {
      AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
    }
    // Patient flow
    else if (userType == "patient") {
      final patient = await FireStoreHelper.fireStoreHelper
          .getPatientFromFireStore(user.uid);
      if (patient == null) {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(MainLayout());
      }
    }
    // Staff flow
    else if (userType == "staff") {
      final staff = await FireStoreHelper.fireStoreHelper.getStaffFromFireStore(
        user.uid,
      );
      if (staff) {
        AppRouter.navigateToWidgetWithReplacment(StaffScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      }
    }
    // Doctor flow
    else if (userType == "doctor") {
      final doctor = await FireStoreHelper.fireStoreHelper
          .getDoctorFromFireStore(user.uid);
      if (doctor == null) {
        AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
      } else {
        AppRouter.navigateToWidgetWithReplacment(MainLayout());
      }
    }
  }

  // Sign out method - clears all user data and navigates to user type screen
  signOut() async {
    await AuthHelper.authHelper.signOut();
    AppRouter.navigateToWidgetWithReplacment(UserTypeScreen());
    // Clear all form controllers and selections
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

  // Patient sign up method
  Future<UserCredential?> userSignUp(AppLocalizations localization) async {
    try {
      isLoading = true;
      notifyListeners();

      // Validate profile image is selected
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
        // Create auth credentials
        UserCredential? credentials = await AuthHelper.authHelper.signUp(
          emailController.text,
          passwordController.text,
          localization,
        );

        if (credentials != null) {
          // Upload profile image
          String? imageUrl = await StorageHelper.storageHelper.uploadImage(
            selectedPatientImage!,
          );

          // Create patient model
          PatientModel patient = PatientModel(
            id: credentials.user!.uid,
            email: emailController.text,
            name: userNameController.text,
            age: ageController.text,
            gender: selectedGender,
            imgUrl: imageUrl ?? "",
          );

          // Save patient to Firestore
          await FireStoreHelper.fireStoreHelper.addUserToFireStore(patient);

          // Navigate to main layout and clear form
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

  // Doctor sign up method
  Future<UserCredential?> doctorSignUp(AppLocalizations localization) async {
    try {
      String? storedStaffPassword;
      isLoading = true;
      notifyListeners();

      // Validate profile image is selected
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
        // Get current staff user (if exists)
        User? currentUser = AuthHelper.authHelper.firebaseAuth.currentUser;
        String? currentUserEmail =
            AuthHelper.authHelper.firebaseAuth.currentUser?.email;

        // Create auth credentials
        UserCredential? credentials = await AuthHelper.authHelper.signUp(
          doctorEmailController.text,
          doctorPasswordController.text,
          localization,
        );

        // Store doctor password
        SpHelper.spHelper.setDoctorPassword(doctorPasswordController.text);

        if (credentials != null) {
          // Upload profile image
          String? doctorImageUrl = await StorageHelper.storageHelper
              .uploadImage(selectedDoctorImage!);

          // Generate random doctor stats
          Random random = Random();

          // Create doctor model
          DoctorModel doctor = DoctorModel(
            id: credentials.user!.uid,
            email: doctorEmailController.text,
            name: doctorUserNameController.text,
            speciality: selectedSpeciality!,
            hospitalName: selectedHospital!,
            imgUrl: doctorImageUrl ?? "",
            patientNumbers: (20 + random.nextInt(31))
                .toString(), // Random patients (20-50)
            experience: (3 + random.nextInt(8))
                .toString(), // Random experience (3-10 years)
            rating: ((random.nextInt(6) + 45) / 10)
                .toString(), // Random rating (4.5-5.1)
          );

          // Save doctor to Firestore
          await FireStoreHelper.fireStoreHelper.addDoctorToFireStore(doctor);

          // Show success message
          CustomShowDialog.showDialogFunction(
            localization.doctorAddSuccess,
            localization,
          );

          // Clear form and reset state
          isLoading = false;
          doctorEmailController.clear();
          doctorUserNameController.clear();
          selectedSpeciality = null;
          selectedHospital = null;
          selectedDoctorImage = null;
          doctorPasswordController.clear();
          notifyListeners();

          // If staff was adding a doctor, sign them back in
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

  // Password reset functionality
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

  // Image picker method for profile pictures
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
