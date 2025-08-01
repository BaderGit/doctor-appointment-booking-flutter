import 'package:final_project/l10n/app_localizations.dart';
import 'package:final_project/models/appointment.dart';
import 'package:final_project/utils/booking_datetime_converted.dart';
import 'package:final_project/models/doctor.dart';
import 'package:final_project/models/patient.dart';
import 'package:final_project/providers/firestore_provider.dart';
import 'package:final_project/utils/config.dart';

import 'package:final_project/views/widgets/general/button.dart';
import 'package:final_project/views/widgets/general/custom_appbar.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class BookingPage extends StatefulWidget {
  BookingPage({
    super.key,
    required this.doctor,
    required this.patient,
    this.isReschedule = false,
    this.existingAppointment,
  });
  DoctorModel doctor;
  PatientModel patient;
  final bool isReschedule;
  final AppointmentModel? existingAppointment;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  late DateTime _focusDay;
  late DateTime _currentDay;
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentDay = now;
    _focusDay = now;
    _lastDay = DateTime(now.year + 1, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final localizations = AppLocalizations.of(context)!;

    return Consumer<FireStoreProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            appTitle: localizations.appointmentTitle,
            icon: const FaIcon(Icons.arrow_back_ios),
          ),
          body: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    _tableCalendar(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 25,
                      ),
                      child: Center(
                        child: Text(
                          localizations.selectConsultationTime,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _isWeekend
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 30,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localizations.weekendNotAvailable,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _currentIndex = index;
                              _timeSelected = true;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              color: _currentIndex == index
                                  ? Config.primaryColor
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 9}:00 ${index + 9 > 11 ? localizations.timePm : localizations.timeAm}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _currentIndex == index
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }, childCount: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 1.5,
                          ),
                    ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 80,
                  ),
                  child: Button(
                    width: double.infinity,
                    title: widget.isReschedule
                        ? localizations.updateAppointment
                        : localizations.makeAppointment,
                    onPressed: () async {
                      if (widget.isReschedule) {
                        final getDate = DateConverted.getDate(_currentDay);
                        final getDay = DateConverted.getDay(
                          _currentDay.weekday,
                        );
                        final getTime = DateConverted.getTime(_currentIndex!);

                        AppointmentModel updatedAppointment = widget
                            .existingAppointment!
                            .copyWith(
                              date: getDate,
                              day: getDay,
                              time: getTime,
                            );
                        await provider.updateAppointment(
                          updatedAppointment,
                          localizations.appointmentUpdatedSuccessfully(
                            widget.doctor.name,
                          ),
                          localizations,
                        );
                        await provider.updateStoredAppointment(
                          updatedAppointment,
                        );
                      } else {
                        final getDate = DateConverted.getDate(_currentDay);
                        final getDay = DateConverted.getDay(
                          _currentDay.weekday,
                        );
                        final getTime = DateConverted.getTime(_currentIndex!);
                        var uuid = Uuid();

                        AppointmentModel newAppointmentModel = AppointmentModel(
                          id: uuid.v1(),
                          doctor: widget.doctor,
                          patient: widget.patient,
                          date: getDate,
                          time: getTime,
                          day: getDay,
                        );

                        await provider.addAppointment(
                          newAppointmentModel,
                          localizations.appointmentScheduledSuccessfully(
                            widget.doctor.name,
                          ),
                          localizations.bookingFailed,
                          localizations,
                        );
                        await provider.storeAppointment(newAppointmentModel);
                      }
                    },
                    disable: _timeSelected && _dateSelected ? false : true,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: _lastDay,
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}
