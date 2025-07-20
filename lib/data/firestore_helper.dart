import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_project/models/patient.dart';
import 'package:final_project/models/appointment.dart';
import 'package:final_project/models/doctor.dart';

class FireStoreHelper {
  FireStoreHelper._();

  static FireStoreHelper fireStoreHelper = FireStoreHelper._();

  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  // Reference to the 'patients' collection
  var paitentCollection = FirebaseFirestore.instance.collection('patients');
  // Reference to the 'doctors' collection
  var doctorCollection = FirebaseFirestore.instance.collection('doctors');
  // Reference to the 'staffs' collection
  var staffCollection = FirebaseFirestore.instance.collection('staffs');
  // Reference to the 'appointments' collection
  var appointmentCollection = FirebaseFirestore.instance.collection(
    'appointments',
  );
  // Reference to the 'stored_appointments' collection (archive/history)
  var storedAppointmentCollection = FirebaseFirestore.instance.collection(
    'stored_appointments',
  );

  // Adds a new patient to Firestore
  Future<bool> addUserToFireStore(PatientModel patient) async {
    await paitentCollection.doc(patient.id).set(patient.toMap());
    return true;
  }

  // Adds a new doctor to Firestore
  addDoctorToFireStore(DoctorModel doctor) async {
    await doctorCollection.doc(doctor.id).set(doctor.toMap());
  }

  // Adds a new appointment to Firestore
  // Returns the appointment ID
  Future<String?> addAppointmentToFireStore(
    AppointmentModel appointment,
  ) async {
    await appointmentCollection.doc(appointment.id).set(appointment.toMap());
    return appointment.id;
  }

  // Stores an appointment in the archive/history collection
  // Returns the appointment ID
  Future<String?> storeAppointmentToFireStore(
    AppointmentModel appointment,
  ) async {
    await storedAppointmentCollection
        .doc(appointment.id)
        .set(appointment.toMap());
    return appointment.id;
  }

  // Retrieves an appointment by ID from Firestore
  // Returns null if not found
  Future<AppointmentModel?>? getAppointmentFromFireStore(String? id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapShot =
          await appointmentCollection.doc(id).get();
      if (documentSnapShot.data() == null) {
        return null;
      }

      return AppointmentModel.fromMap(documentSnapShot.data()!);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  // Retrieves a patient by ID from Firestore
  Future<PatientModel?>? getPatientFromFireStore(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapShot =
        await paitentCollection.doc(id).get();
    Map<String, dynamic>? data = documentSnapShot.data();
    if (data != null) {
      return PatientModel?.fromMap(data);
    }
    return null;
  }

  // Checks if a staff member exists in Firestore by ID
  Future<bool> getStaffFromFireStore(String? id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapShot =
        await staffCollection.doc(id).get();
    Map<String, dynamic>? data = documentSnapShot.data();

    if (data != null) {
      return true;
    }
    return false;
  }

  // Retrieves a doctor by ID from Firestore
  Future<DoctorModel?>? getDoctorFromFireStore(String? id) async {
    DocumentSnapshot<Map<String, dynamic>>? documentSnapShot =
        await doctorCollection.doc(id).get();

    Map<String, dynamic>? data = documentSnapShot.data();
    if (data != null) {
      return DoctorModel?.fromMap(data);
    }
    return null;
  }

  // Retrieves all doctors from Firestore
  Future<List<DoctorModel>> getAllDoctors() async {
    var doctorsQuerySnapShot = await doctorCollection.get();
    List<DoctorModel> allDoctors = doctorsQuerySnapShot.docs
        .map((e) => DoctorModel.fromMap(e.data()))
        .toList();
    return allDoctors;
  }

  // Retrieves all appointments from Firestore
  Future<List<AppointmentModel>> getAllAppointments() async {
    var appointmentsQuerySnapShot = await appointmentCollection.get();
    List<AppointmentModel> allAppointments = appointmentsQuerySnapShot.docs
        .map((e) => AppointmentModel.fromMap(e.data()))
        .toList();
    return allAppointments;
  }

  // Retrieves all stored (history) appointments from Firestore
  Future<List<AppointmentModel>> getAllStoredAppointments() async {
    var storedAppointmentsQuerySnapShot = await storedAppointmentCollection
        .get();
    List<AppointmentModel> allStoredAppointments =
        storedAppointmentsQuerySnapShot.docs
            .map((e) => AppointmentModel.fromMap(e.data()))
            .toList();
    return allStoredAppointments;
  }

  // Deletes an appointment by ID from Firestore
  deleteAppointmentFromFireStore(String id) async {
    try {
      await appointmentCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // Deletes a doctor by ID from Firestore
  deleteDoctorFromFireStore(String id) async {
    try {
      await doctorCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // Deletes a stored (history) appointment by ID from Firestore
  deleteStoredAppointmentFromFireStore(String id) async {
    try {
      await storedAppointmentCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // Updates an existing appointment in Firestore
  updateAppointmentInFireStore(AppointmentModel appointment) async {
    try {
      await appointmentCollection
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  // Updates an existing stored (history) appointment in Firestore
  updateStoredAppointmentInFireStore(AppointmentModel appointment) async {
    try {
      await storedAppointmentCollection
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      print('Error updating document: $e');
    }
  }
}
