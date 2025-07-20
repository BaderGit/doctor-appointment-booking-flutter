import 'dart:developer';

// Importing helper classes, models, and utilities
import 'package:final_project/data/auth_helper.dart';
import 'package:final_project/data/firestore_helper.dart';
import 'package:final_project/data/sp_helper.dart';
import 'package:final_project/l10n/app_localizations.dart';
import 'package:final_project/models/appointment.dart';
import 'package:final_project/models/patient.dart';
import 'package:final_project/models/doctor.dart';
import 'package:final_project/utils/custom_dialog.dart';
import 'package:final_project/utils/local_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Provider class for managing Firestore data operations and state
class FireStoreProvider extends ChangeNotifier {
  // Current patient data
  PatientModel? patient;

  // Current doctor data
  DoctorModel? doctor;

  // Lists for storing various data from Firestore
  List<DoctorModel?> allDoctors = [];
  List<AppointmentModel?> allAppointments = [];
  List<AppointmentModel?> allStoredAppointments = [];
  List<AppointmentModel?> patienttodaysAppointments = [];

  // Filtered doctors list for UI display
  List<DoctorModel?> filteredDoctors = [];

  // Current selected category for filtering
  String currentCat = "";

  // Loading state indicator
  bool isLoading = false;

  // Fetches patient data from Firestore and updates related appointments
  getPatient() async {
    patient = await FireStoreHelper.fireStoreHelper.getPatientFromFireStore(
      AuthHelper.authHelper.getUserId(),
    );
    notifyListeners();
    await getAllAppointments();
    await getAllStoredAppointments();
  }

  // Fetches doctor data from Firestore
  getDoctor() async {
    doctor = await FireStoreHelper.fireStoreHelper.getDoctorFromFireStore(
      AuthHelper.authHelper.getUserId(),
    );
    allDoctors.add(doctor);
    notifyListeners();
  }

  // Gets a single appointment by ID and refreshes appointments list
  Future<AppointmentModel?>? getAppointment(String id) async {
    AppointmentModel? appointmentModel = await FireStoreHelper.fireStoreHelper
        .getAppointmentFromFireStore(id);

    getAllAppointments();

    return appointmentModel;
  }

  // Fetches all appointments and sorts them by date and time
  getAllAppointments() async {
    allAppointments = await FireStoreHelper.fireStoreHelper
        .getAllAppointments();
    // Sort appointments chronologically
    allAppointments.sort((app1, app2) {
      final app1Date = DateFormat(
        'M/dd/yyyy HH:mm',
      ).parse("${app1!.date} ${app1.time}");

      final app2Date = DateFormat(
        'M/dd/yyyy HH:mm',
      ).parse("${app2!.date} ${app2.time}");

      return app1Date.compareTo(app2Date);
    });

    notifyListeners();
  }

  // Fetches all doctors from Firestore
  getAllDoctors() async {
    allDoctors = await FireStoreHelper.fireStoreHelper.getAllDoctors();
    notifyListeners();
  }

  // Updates the filtered doctors list based on selected category
  updateCurrentDoctors(
    String category,
    Function getSpecailityLocalization,
    AppLocalizations localizations,
  ) {
    // Toggle category selection
    currentCat = currentCat == category ? "" : category;

    // Filter doctors based on selected category
    if (currentCat == "") {
      filteredDoctors = allDoctors;
    } else {
      filteredDoctors = allDoctors
          .where(
            (doctor) =>
                getSpecailityLocalization(
                  doctor!.speciality.toLowerCase(),
                  localizations,
                ) ==
                currentCat.toLowerCase(),
          )
          .toList();
    }

    notifyListeners();
  }

  // Deletes an appointment from Firestore and updates local state
  deleteAppointment(String id) async {
    await FireStoreHelper.fireStoreHelper.deleteAppointmentFromFireStore(id);
    allAppointments.removeWhere((appointment) => appointment!.id == id);

    notifyListeners();

    await getAllAppointments();
    await getTodaysAppointment();
  }

  // Deletes a doctor account and associated data
  deleteDoctor(String id) async {
    isLoading = true;
    notifyListeners();
    final firebaseAuth = AuthHelper.authHelper.firebaseAuth;

    // Get stored credentials
    String? doctorPassword = await SpHelper.spHelper.getDoctorPassword();
    String? staffEmail = await SpHelper.spHelper.getStaffEmail();
    String? staffPassword = await SpHelper.spHelper.getStaffPassword();

    // Sign out current user
    await AuthHelper.authHelper.signOut();

    // Get doctor data before deletion
    var doctor = await FireStoreHelper.fireStoreHelper.getDoctorFromFireStore(
      id,
    );

    // Sign in as doctor to delete account
    await firebaseAuth.signInWithEmailAndPassword(
      email: doctor!.email,
      password: doctorPassword ?? "",
    );

    // Delete doctor account
    await firebaseAuth.currentUser!.delete();

    // Delete doctor data from Firestore
    await FireStoreHelper.fireStoreHelper.deleteDoctorFromFireStore(id);
    allDoctors.removeWhere((appointment) => appointment!.id == id);

    // Refresh doctors list
    await getAllDoctors();

    // Sign back in as staff
    await firebaseAuth.signInWithEmailAndPassword(
      email: staffEmail ?? "",
      password: staffPassword ?? "",
    );
    isLoading = false;
    notifyListeners();
  }

  // Deletes a stored (archived) appointment
  deleteStoredAppointment(String id) async {
    await FireStoreHelper.fireStoreHelper.deleteStoredAppointmentFromFireStore(
      id,
    );
    allStoredAppointments.removeWhere((appointment) => appointment!.id == id);

    notifyListeners();

    await getAllStoredAppointments();
  }

  // Updates an appointment in Firestore and local state
  updateAppointment(
    AppointmentModel updatedAppointment,
    String success,
    AppLocalizations localization,
  ) async {
    isLoading = true;
    notifyListeners();
    await FireStoreHelper.fireStoreHelper.updateAppointmentInFireStore(
      updatedAppointment,
    );
    final index = allAppointments.indexWhere(
      (appointment) => appointment!.id == updatedAppointment.id,
    );
    if (index != -1) {
      allAppointments[index] = updatedAppointment;
      CustomShowDialog.showDialogFunction(success, localization);
      isLoading = false;
      notifyListeners();
    }
    await getAllAppointments();
    await getAllStoredAppointments();
    await getTodaysAppointment();
  }

  // Updates a stored (archived) appointment
  updateStoredAppointment(AppointmentModel updatedAppointment) async {
    await FireStoreHelper.fireStoreHelper.updateStoredAppointmentInFireStore(
      updatedAppointment,
    );

    final index = allStoredAppointments.indexWhere(
      (appointment) => appointment!.id == updatedAppointment.id,
    );
    if (index != -1) {
      allStoredAppointments[index] = updatedAppointment;
      notifyListeners();
    }

    await getAllAppointments();
    await getAllStoredAppointments();
  }

  // Adds a new appointment with validation and notification
  addAppointment(
    AppointmentModel appointment,
    String content,
    String failed,
    AppLocalizations localization,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      // Check for duplicate appointments
      final index = allAppointments.indexWhere((app) {
        return app!.date == appointment.date &&
            app.time == appointment.time &&
            app.doctor.id == appointment.doctor.id;
      });
      if (index != -1) {
        CustomShowDialog.showDialogFunction(failed, localization);
        return;
      }

      // Add appointment to Firestore
      await FireStoreHelper.fireStoreHelper.addAppointmentToFireStore(
        appointment,
      );

      // Show success message and set notification
      CustomShowDialog.showDialogFunction(content, localization);
      LocalNotification.localNotification.getRightTime(appointment);

      // Refresh appointment lists
      await getAllAppointments();
      await getTodaysAppointment();
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Stores an appointment in the archive collection
  storeAppointment(AppointmentModel appointment) async {
    // Check for duplicates
    final index = allStoredAppointments.indexWhere((app) {
      return app!.date == appointment.date && app.time == appointment.time;
    });
    if (index != -1) {
      return;
    }

    // Add to stored appointments
    await FireStoreHelper.fireStoreHelper.storeAppointmentToFireStore(
      appointment,
    );
    await getAllStoredAppointments();
  }

  // Fetches all stored (archived) appointments
  getAllStoredAppointments() async {
    allStoredAppointments = await FireStoreHelper.fireStoreHelper
        .getAllStoredAppointments();
    notifyListeners();
  }

  // Gets today's appointments for the current patient
  getTodaysAppointment() {
    var now = DateTime.now();
    var todaysDate = DateFormat('M/d/yyyy').format(now);
    List<AppointmentModel?> allPatientAppointments = [];

    // Filter appointments for current patient
    allPatientAppointments = allAppointments
        .where((appointment) => appointment!.patient.id == patient!.id)
        .toList();

    // Filter for today's appointments and sort by time
    patienttodaysAppointments = allPatientAppointments
        .where((appointment) => appointment!.date == todaysDate)
        .toList();
    patienttodaysAppointments.sort(
      (app1, app2) => app2!.time.compareTo(app1!.time),
    );

    notifyListeners();
  }
}
