import 'package:final_project/providers/auth_provider.dart';
import 'package:final_project/providers/firestore_provider.dart';
import 'package:final_project/providers/language_provider.dart';
import 'package:final_project/utils/app_router.dart';
import 'package:final_project/utils/config.dart';
import 'package:final_project/views/widgets/general/button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';

class AddNewDoctorScreen extends StatefulWidget {
  const AddNewDoctorScreen({super.key});

  @override
  AddNewDoctorScreenState createState() => AddNewDoctorScreenState();
}

class AddNewDoctorScreenState extends State<AddNewDoctorScreen> {
  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    List<Map<String, dynamic>> medCat = [
      {
        "icon": FontAwesomeIcons.userDoctor,
        "category": "general",
        "hospitalName": "sarawak general hospital",
      },
      {
        "icon": FontAwesomeIcons.heartPulse,
        "category": "cardiology",
        "hospitalName": "royal cardiac center",
      },
      {
        "icon": FontAwesomeIcons.lungs,
        "category": "respirations",
        "hospitalName": "nova care hospital",
      },
      {
        "icon": FontAwesomeIcons.hand,
        "category": "dermatology",
        "hospitalName": "harmony general hospital",
      },
      {
        "icon": FontAwesomeIcons.personPregnant,
        "category": "gynecology",
        "hospitalName": "apex medical hub",
      },
      {
        "icon": FontAwesomeIcons.teeth,
        "category": "dental",
        "hospitalName": "zenith health campus",
      },
    ];

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
                          localizations.addNewDoctor,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        IconButton(
                          onPressed: () async {
                            await fireStore.getAllDoctors();
                            AppRouter.popRoute();
                            auth.doctorEmailController.clear();
                            auth.doctorPasswordController.clear();
                            auth.doctorUserNameController.clear();
                            auth.selectedDoctorImage = null;
                            auth.selectedHospital = null;
                            auth.selectedSpeciality = null;
                          },
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    Form(
                      key: auth.signUpKey,
                      child: Column(
                        children: [
                          Config.spaceSmall,
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  auth.pickImage();
                                },
                                child: CircleAvatar(
                                  radius: 64,
                                  backgroundImage:
                                      auth.selectedDoctorImage != null
                                      ? FileImage(auth.selectedDoctorImage!)
                                      : const AssetImage(
                                              "assets/anonymous_profile.jpg",
                                            )
                                            as ImageProvider,
                                ),
                              ),
                              Positioned(
                                bottom: -10,
                                right: 80,
                                child: IconButton(
                                  onPressed: () {
                                    auth.pickImage();
                                  },
                                  icon: Icon(
                                    size: 30,
                                    Icons.add_a_photo,
                                    color: Config.primaryColor,
                                  ),
                                  tooltip: localizations.uploadPhoto,
                                ),
                              ),
                            ],
                          ),
                          Config.spaceSmall,

                          TextFormField(
                            validator: (value) =>
                                auth.nullValidation(value, localizations),
                            controller: auth.doctorUserNameController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Config.primaryColor,
                            decoration: InputDecoration(
                              hintText: localizations.fullNameHint,
                              labelText: localizations.fullNameLabel,
                              prefixIcon: const Icon(Icons.person_outline),
                              prefixIconColor: Config.primaryColor,
                            ),
                          ),
                          Config.spaceSmall,
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            validator: (value) =>
                                auth.nullValidation(value, localizations),
                            decoration: InputDecoration(
                              hintText: localizations.specialityHint,
                              labelText: localizations.specialityLabel,
                              prefixIcon: const Icon(
                                Icons.medical_services_outlined,
                              ),
                              prefixIconColor: Config.primaryColor,
                            ),
                            value: auth.selectedSpeciality,

                            onChanged: (String? newValue) {
                              setState(() {
                                auth.selectedSpeciality = newValue;
                              });
                            },
                            items: medCat.map<DropdownMenuItem<String>>((
                              value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value["category"],
                                child: Text(
                                  lang.getSpecialityLocalization(
                                    value["category"],
                                    localizations,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Config.spaceSmall,
                          DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            validator: (value) =>
                                auth.nullValidation(value, localizations),
                            decoration: InputDecoration(
                              hintText: localizations.hospitalNamehint,
                              labelText: localizations.hospitalNameLabel,
                              prefixIcon: const Icon(
                                Icons.local_hospital_sharp,
                              ),
                              prefixIconColor: Config.primaryColor,
                            ),
                            value: auth.selectedHospital,
                            onChanged: (String? newValue) {
                              setState(() {
                                auth.selectedHospital = newValue;
                              });
                            },
                            items: medCat.map<DropdownMenuItem<String>>((
                              value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value["hospitalName"],
                                child: Text(
                                  lang.getHospitalNameLocalization(
                                    value["hospitalName"],
                                    localizations,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Config.spaceSmall,

                          TextFormField(
                            validator: (value) =>
                                auth.emailValidation(value, localizations),
                            controller: auth.doctorEmailController,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Config.primaryColor,
                            decoration: InputDecoration(
                              hintText: localizations.emailHint,
                              labelText: localizations.emailLabel,
                              prefixIcon: const Icon(Icons.email_outlined),
                              prefixIconColor: Config.primaryColor,
                            ),
                          ),
                          Config.spaceSmall,
                          TextFormField(
                            validator: (value) =>
                                auth.passwordValidation(value, localizations),
                            controller: auth.doctorPasswordController,
                            keyboardType: TextInputType.visiblePassword,
                            cursorColor: Config.primaryColor,
                            obscureText: obsecurePass,
                            decoration: InputDecoration(
                              hintText: localizations.passwordHint,
                              labelText: localizations.passwordLabel,
                              alignLabelWithHint: true,
                              prefixIcon: const Icon(Icons.lock_outline),
                              prefixIconColor: Config.primaryColor,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obsecurePass = !obsecurePass;
                                  });
                                },
                                icon: obsecurePass
                                    ? const Icon(
                                        Icons.visibility_off_outlined,
                                        color: Colors.black38,
                                      )
                                    : const Icon(
                                        Icons.visibility_outlined,
                                        color: Config.primaryColor,
                                      ),
                                tooltip: obsecurePass
                                    ? localizations.showPassword
                                    : localizations.hidePassword,
                              ),
                            ),
                          ),
                          Config.spaceSmall,
                          Button(
                            width: double.infinity,
                            title: localizations.addNewDoctor,
                            onPressed: () async {
                              await auth.doctorSignUp(localizations);
                            },
                            disable: false,
                          ),
                          Config.spaceSmall,
                          Center(
                            child: TextButton(
                              child: Text(
                                localizations.changeLanguage,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              onPressed: () {
                                lang.toggleLanguage();
                              },
                            ),
                          ),
                        ],
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
