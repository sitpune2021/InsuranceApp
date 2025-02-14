// appointment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/services/auth.dart';

class AppointmentProvider extends ChangeNotifier {
  int _totalAppCount = 0;
  int _todaysAppCount = 0;
  int _scheduleCount = 0;
  int _pendingCount = 0;
  List<Appointment> _appointments = [];
  List<Appointment> get appointments => _appointments;
  // Getters
  int get totalAppCount => _totalAppCount;
  int get todaysAppCount => _todaysAppCount;
  int get scheduleCount => _scheduleCount;
  int get pendingCount => _pendingCount;

  // Initialize and fetch all counts
  Future<void> fetchAllCounts() async {
    await Future.wait([
      fetchTotalAppointments(),
      fetchTodayAppointments(),
      fetchScheduleAppointments(),
      fetchPendingAppointments(),
    ]);
  }

  Future<void> fetchTotalAppointments() async {
    List<Appointment> fetchedAppointments = await Auth().getTotalAppointments();
    _appointments = fetchedAppointments;
    _totalAppCount = _appointments.length;
    notifyListeners();
  }

  Future<List<Appointment>> fetchTotalAppointment() async {
    List<Appointment> appointments = await Auth().getTotalAppointments();

    notifyListeners();
    return appointments;
  }

  Future<void> fetchTodayAppointments() async {
    List<Appointment> appointments = await Auth().getTodaysAppointments();
    _todaysAppCount = appointments.length;
    notifyListeners();
  }

  Future<void> fetchScheduleAppointments() async {
    List<Appointment> appointments = await Auth().getScheduleAppointments();
    _scheduleCount = appointments.length;
    notifyListeners();
  }

  Future<void> fetchPendingAppointments() async {
    List<Appointment> appointments = await Auth().getPendingAppointments();
    _pendingCount = appointments.length;
    notifyListeners();
  }
}
