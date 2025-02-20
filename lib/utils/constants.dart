class Constants {
  // static const String loginAssistanturl =
  //     "http://192.168.1.57:8085/checkLoginAssistant";
  static const String loginAssistanturl =
      "http://192.168.1.57:8085/checkLoginAssistant";
  static const String totalAppointmentUrl =
      "http://192.168.1.57:8085/getassignappointmentfortechnician?technician_id=";

  static const String todaysAppointmentUrl =
      "http://192.168.1.57:8085/gettodayappointment?technician_id=";

  static const String pendingAppointmentUrl =
      "http://192.168.1.57:8085/getpendingappointment?technician_id=";

  static const String scheduleAppointmentUrl =
      "http://192.168.1.57:8085/getscheduleappointment?technician_id=";

  static const String otpUrl = "http://192.168.1.57:8085/sendOTP";

  static const String confirmNewPasswordUrl =
      "http://192.168.1.57:8085/forgetpassword";

  static const String updateStatusOfSubmittedAppointment =
      "http://192.168.1.57:8085/updateAppointmentStatus/";

  static const String addAppointmentsubmit =
      "http://192.168.1.57:8085/addappointmentapp";
  static const String completedAppointments =
      "http://192.168.1.57:8085/getcompletedappointmentfortechnician?technician_id=";

  static const String updateFcmToken =
      "http://192.168.1.57:8085/updateFcmToken";

  static const String rejectAppointment =
      "http://192.168.1.57:8085/rejectedappointmentapp";

  static const String deleteUser = "http://192.168.1.57:8085/deleteassistant/";
  static const String testRemarks = "http://192.168.1.57:8085/gettestremarkapp";
}
