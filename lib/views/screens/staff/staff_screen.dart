import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/providers/firestore_provider.dart';
import 'package:final_project/providers/language_provider.dart';
import 'package:final_project/utils/app_router.dart';
import 'package:final_project/utils/config.dart';
import 'package:final_project/views/screens/staff/add_new_doctor.dart';

import 'package:final_project/views/widgets/doctor/doctor_card.dart';
import 'package:final_project/views/widgets/general/button.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  StaffScreenState createState() => StaffScreenState();
}

class StaffScreenState extends State<StaffScreen> {
  bool obsecurePass = true;

  @override
  void initState() {
    super.initState(); // This must be called first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fireStore = Provider.of<FireStoreProvider>(context, listen: false);
      await fireStore.getAllDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer3<AppAuthProvider, FireStoreProvider, LanguageProvider>(
      builder: (context, auth, fireStore, lang, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          localizations.welcomeAdmin,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () {
                            lang.toggleLanguage();
                          },
                          icon: Icon(Icons.language),
                        ),
                        IconButton(
                          onPressed: () {
                            auth.signOut();
                          },
                          icon: const Icon(Icons.logout),
                          tooltip: localizations.logout,
                        ),
                      ],
                    ),
                    Config.spaceSmall,

                    Button(
                      width: double.infinity,
                      title: localizations.addNewDoctor,
                      onPressed: () {
                        AppRouter.navigateToWidget(AddNewDoctorScreen());
                      },
                      disable: false,
                    ),
                    Config.spaceSmall,
                    Column(
                      children: fireStore.allDoctors.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.only(top: 160),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: fireStore.allDoctors.isEmpty
                                      ? [
                                          Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Icon (matches your upcoming appointments style)
                                                Icon(
                                                  Icons
                                                      .medical_services_outlined, // Medical icon for doctors
                                                  size: 60,
                                                  color: Colors.grey.withAlpha(
                                                    102,
                                                  ), // Same opacity as your design
                                                ),
                                                const SizedBox(height: 20),
                                                // Primary message (bold and slightly larger)
                                                Text(
                                                  localizations.noDoctors,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey
                                                        .withAlpha(
                                                          179,
                                                        ), // Same as your text
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        ]
                                      : List.generate(
                                          fireStore.allDoctors.length,
                                          (index) => DoctorCard(
                                            doctor: fireStore.allDoctors[index],
                                            isStaff: true,
                                          ),
                                        ),
                                ),
                              ),
                            ]
                          : List.generate(
                              fireStore.allDoctors.length,
                              (index) => DoctorCard(
                                doctor: fireStore.allDoctors[index],
                                isStaff: true,
                              ),
                            ),
                    ),
                    // Column(
                    //   children: fireStore.allDoctors.isEmpty
                    //       ? [     Center(
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(
                    //               Icons.calendar_today_outlined,
                    //               size: 60,
                    //               color: Colors.grey.withAlpha(102),
                    //             ),
                    //             const SizedBox(height: 20),
                    //             Text(
                    //               localizations.noDoctorsAvailable,
                    //               style: TextStyle(
                    //                 fontSize: 18,
                    //                 color: Colors.grey.withAlpha(179),
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 10),
                    //             Text(
                    //               localizations.upcomingAppointments,
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 color: Colors.grey.withAlpha(128),
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),Text(localizations.noDoctorsAvailable)]
                    //       : List.generate(
                    //           fireStore.allDoctors.length,
                    //           (index) => DoctorCard(
                    //             doctor: fireStore.allDoctors[index],
                    //             isStaff: true,
                    //           ),
                    //         ),
                    // ),
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
