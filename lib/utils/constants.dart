class Constants {
  // static const String loginAssistanturl =
  //     "http://192.168.1.57:3005/checkLoginAssistant";
  static const String loginAssistanturl =
      "http://192.168.1.57:3005/checkLoginAssistant";
  static const String totalAppointmentUrl =
      "http://192.168.1.57:3005/getassignappointmentfortechnician?technician_id=";

  static const String todaysAppointmentUrl =
      "http://192.168.1.57:3005/gettodayappointment?technician_id=";

  static const String pendingAppointmentUrl =
      "http://192.168.1.57:3005/getpendingappointment?technician_id=";

  static const String scheduleAppointmentUrl =
      "http://192.168.1.57:3005/getscheduleappointment?technician_id=";

  static const String otpUrl = "http://192.168.1.57:3005/sendOTP";

  static const String confirmNewPasswordUrl =
      "http://192.168.1.57:3005/forgetpassword";

  static const String updateStatusOfSubmittedAppointment =
      "http://192.168.1.57:3005/updateAppointmentStatus/";

  static const String addAppointmentsubmit =
      "http://192.168.1.57:3005/addappointmentapp";
  static const String completedAppointments =
      "http://192.168.1.57:3005/getcompletedappointmentfortechnician?technician_id=";
}
