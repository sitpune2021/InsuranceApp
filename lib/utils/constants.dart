class Constants {
  // static const String loginAssistanturl =
  //     "http://103.165.118.71:8085/checkLoginAssistant";
  static const String loginAssistanturl =
      "http://103.165.118.71:8085/checkLoginAssistant";
  static const String totalAppointmentUrl =
      "http://103.165.118.71:8085/getassignappointmentfortechnician?technician_id=";

  static const String todaysAppointmentUrl =
      "http://103.165.118.71:8085/gettodayappointment?technician_id=";

  static const String pendingAppointmentUrl =
      "http://103.165.118.71:8085/getpendingappointment?technician_id=";

  static const String scheduleAppointmentUrl =
      "http://103.165.118.71:8085/getscheduleappointment?technician_id=";

  static const String otpUrl = "http://103.165.118.71:8085/sendOTP";

  static const String confirmNewPasswordUrl =
      "http://103.165.118.71:8085/forgetpassword";

  static const String updateStatusOfSubmittedAppointment =
      "http://103.165.118.71:8085/updateAppointmentStatus/";

  static const String addAppointmentsubmit =
      "http://103.165.118.71:8085/addappointmentapp";
  static const String completedAppointments =
      "http://103.165.118.71:8085/getcompletedappointmentfortechnician?technician_id=";

  static const String updateFcmToken =
      "http://103.165.118.71:8085/updateFcmToken";

  static const String rejectAppointment =
      "http://103.165.118.71:8085/rejectedappointmentapp";

  static const String deleteUser =
      "http://103.165.118.71:8085/deleteassistant/";
  static const String testRemarks =
      "http://103.165.118.71:8085/gettestremarkapp";

  static const String getgetCompletedAppointmentByTechnician =
      "http://103.165.118.71:8085/getCompletedAppointmentByTechnician/";

  //_baseUrl = "http://103.165.118.71:8085" this is base url used directly in CompltedappointmentDetails file need to make it dynamic.
}
