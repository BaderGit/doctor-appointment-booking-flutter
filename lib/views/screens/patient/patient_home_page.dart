import 'package:final_project/providers/firestore_provider.dart';
import 'package:final_project/providers/language_provider.dart';
import 'package:final_project/utils/config.dart';
import 'package:final_project/views/widgets/appointment/appointment_card.dart';
import 'package:final_project/views/widgets/general/category_card.dart';
import 'package:final_project/views/widgets/doctor/doctor_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:final_project/l10n/app_localizations.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final localizations = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> medCat = [
      {"icon": FontAwesomeIcons.userDoctor, "category": localizations.general},
      {
        "icon": FontAwesomeIcons.heartPulse,
        "category": localizations.cardiology,
      },
      {"icon": FontAwesomeIcons.lungs, "category": localizations.respirations},
      {"icon": FontAwesomeIcons.hand, "category": localizations.dermatology},
      {
        "icon": FontAwesomeIcons.personPregnant,
        "category": localizations.gynecology,
      },
      {"icon": FontAwesomeIcons.teeth, "category": localizations.dental},
    ];

    return Consumer2<FireStoreProvider, LanguageProvider>(
      builder: (context, fireStore, lang, child) {
        return Scaffold(
          body: fireStore.patient == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${localizations.welcome} ${fireStore.patient!.name}",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    fireStore.patient!.imgUrl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Config.spaceSmall,
                          Text(
                            localizations.appointmentToday,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Config.spaceSmall,
                          fireStore.patienttodaysAppointments.isNotEmpty
                              ? AppointmentCard(
                                  doctor: fireStore
                                      .patienttodaysAppointments[0]!
                                      .doctor,
                                  appointment:
                                      fireStore.patienttodaysAppointments[0]!,
                                  color: Config.primaryColor,
                                )
                              : Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        localizations.noAppointmentToday,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          Config.spaceSmall,
                          Text(
                            localizations.category,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Config.spaceSmall,
                          SizedBox(
                            height: Config.heightSize * 0.05,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List<Widget>.generate(medCat.length, (
                                index,
                              ) {
                                return GestureDetector(
                                  onTap: () {
                                    fireStore.updateCurrentDoctors(
                                      medCat[index]["category"],
                                      lang.getSpecialityLocalization,
                                      localizations,
                                    );
                                  },
                                  child: CategoryCard(
                                    catName: medCat[index]["category"],
                                    catIcon: medCat[index]["icon"],
                                    currentCat: fireStore.currentCat,
                                  ),
                                );
                              }),
                            ),
                          ),
                          Config.spaceSmall,
                          Text(
                            localizations.topDoctors,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Config.spaceSmall,
                          Column(
                            children: fireStore.currentCat == ""
                                ? List.generate(
                                    fireStore.allDoctors.length,
                                    (index) => DoctorCard(
                                      doctor: fireStore.allDoctors[index],
                                    ),
                                  )
                                : fireStore.filteredDoctors.isEmpty
                                ? [Text(localizations.noDoctorsAvailable)]
                                : List.generate(
                                    fireStore.filteredDoctors.length,
                                    (index) => DoctorCard(
                                      doctor: fireStore.filteredDoctors[index],
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
