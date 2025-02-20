import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/model/user.dart';
import 'package:insurance/services/notification_service.dart';
import 'package:insurance/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  Future<bool> loginAssistant(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.loginAssistanturl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, dynamic>{'mobileno': name, 'password': password}),
      );
      if (kDebugMode) {
        print("Login response:$response");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonresponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("jsonresponse: $jsonresponse");
        }
        if (jsonresponse['status'] == "1") {
          Map<String, dynamic> userJson = jsonresponse['user'];

          User user = User.fromJson(userJson);

          // Store session data using shared_preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("isLoggedIn", true);
          prefs.setInt("id", user.id);
          prefs.setString('name', user.name); // Store additional data as neede
          prefs.setString('userMobile', user.mobileno);
          prefs.setString('email', user.email);
          prefs.setString('username', user.username);

          print("userdata :$user");

          final fcmtoken = await NotificationService.intance.getFcmToken();
          if (fcmtoken != null) {
            // Send the FCM token to the backend
            final fcmresponse = await http.post(
              Uri.parse(Constants.updateFcmToken),
              headers: <String, String>{'Content-Type': 'application/json'},
              body: jsonEncode(
                <String, dynamic>{'mobileno': name, 'fcmtokenkey': fcmtoken},
              ),
            );

            if (fcmresponse.statusCode == 200) {
              print("FCM token successfully updated on the server.");
            } else {
              print("Failed to update FCM token on the server.");
            }
          } else {
            print("FCM token is null. Can't send it to the server.");
          }

          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login Error $e");
      }
      return false;
    }
    return false;
  }

  Future<List<Appointment>> getTotalAppointments() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userid = preferences.getInt("id");
    try {
      String url = Constants.totalAppointmentUrl;
      final response = await http.get(Uri.parse(url + userid.toString()));
      print("responselist ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Parse the JSON data into a list of Appointment objects
        List<Appointment> appointments = responseData.map((data) {
          return Appointment.fromJson(data);
        }).toList();

        // Debugging print statement
        if (kDebugMode) {
          print("Fetched Appointments total: $appointments");
        }
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      return []; // Return an empty list in case of an error
    }
  }

  Future<List<Appointment>> getTodaysAppointments() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? userid = preferences.getInt("id");
      final response = await http
          .get(Uri.parse(Constants.todaysAppointmentUrl + userid.toString()));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Parse the JSON data into a list of Appointment objects
        List<Appointment> appointments = responseData.map((data) {
          return Appointment.fromJson(data);
        }).toList();

        // Debugging print statement
        if (kDebugMode) {
          print("Fetched Appointments: $appointments");
        }
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      return []; // Return an empty list in case of an error
    }
  }

  Future<List<Appointment>> getPendingAppointments() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? userid = preferences.getInt("id");
      final response = await http
          .get(Uri.parse(Constants.pendingAppointmentUrl + userid.toString()));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Parse the JSON data into a list of Appointment objects
        List<Appointment> appointments = responseData.map((data) {
          return Appointment.fromJson(data);
        }).toList();

        // Debugging print statement
        if (kDebugMode) {
          print("Fetched Appointments: $appointments");
        }
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      return []; // Return an empty list in case of an error
    }
  }

  Future<List<Appointment>> getScheduleAppointments() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? userid = preferences.getInt("id");
      final response = await http
          .get(Uri.parse(Constants.scheduleAppointmentUrl + userid.toString()));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Parse the JSON data into a list of Appointment objects
        List<Appointment> appointments = responseData.map((data) {
          return Appointment.fromJson(data);
        }).toList();

        // Debugging print statement
        if (kDebugMode) {
          print("Fetched Appointments: $appointments");
        }
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      return []; // Return an empty list in case of an error
    }
  }

  Future<bool> sendOtp(String moblieno) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.otpUrl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'mobileno': moblieno,
        }),
      );
      if (kDebugMode) {
        print("Login response:$response");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonresponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("jsonresponse: $jsonresponse");
        }
        if (jsonresponse['success'] == true) {
          final otp = jsonresponse['data']['otp'];
          final mobilenooo = jsonresponse['data']['mobileno'];
          print("otp$otp");

          // Store session data using shared_preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt("otp", otp);
          prefs.setString("resetPasswordMobNo", mobilenooo);
          // prefs.setString('name', user.name); // Store additional data as neede
          // prefs.setString('userMobile', user.mobileno);
          // prefs.setString('email', user.email);
          // prefs.setString('username', user.username);

          // print("userdata :$user");
          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login Error $e");
      }
      return false;
    }
    return false;
  }

  Future<bool> ConfrimNewPassword(String moblieno, String password) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.confirmNewPasswordUrl),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
            <String, dynamic>{'mobileno': moblieno, 'newPassword': password}),
      );
      if (kDebugMode) {
        print("new pass response:$response");
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonresponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("jsonresponse: $jsonresponse");
        }
        if (jsonresponse['success'] == true) {
          final message = jsonresponse['message'];
          print("otp$message");

          // Store session data using shared_preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("Confirmpassmsg", message);

          return true;
        }
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("confirm pass Error $e");
      }
      return false;
    }
    return false;
  }

  Future<List<Appointment>> getCompletedAppointments() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userid = preferences.getInt("id");
    try {
      String url = Constants.completedAppointments + userid.toString();
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Parse the JSON data into a list of Appointment objects
        List<Appointment> appointments = responseData.map((data) {
          return Appointment.fromJson(data);
        }).toList();

        // Debugging print statement
        if (kDebugMode) {
          print("Fetched Appointments: $appointments");
        }
        return appointments;
      } else {
        throw Exception(
            'Failed to load appointments. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
      return []; // Return an empty list in case of an error
    }
  }

  Future<bool> rejectAppointment(int appointmentId, String reason) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      int? userid = preferences.getInt("id");
      final response = await http.post(
        Uri.parse(Constants.rejectAppointment),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          "appointment_id": appointmentId,
          "technician_id": userid,
          "reason": reason,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonresponse = jsonDecode(response.body);
        if (kDebugMode) {
          print("rejected response$jsonresponse");
        }
        return true;
      } else {
        if (kDebugMode) {
          print("rejected response not working");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching appointments: $e");
      }
    }

    return false;
  }

  void sendTokenToBackend(String? fcmtoken) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final name = preferences.get("userMobile");

    if (fcmtoken != null) {
      final response = await http.post(
        Uri.parse(Constants.updateFcmToken),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
          <String, dynamic>{'mobileno': name, 'fcmtokenkey': fcmtoken},
        ),
      );

      if (response.statusCode == 200) {
        print("Token updated successfully");
      } else {
        print("Failed to update token");
      }
    }
  }

  Future<bool> deleteAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userid = prefs.getInt("id");
      final response = await http.put(
        Uri.parse(Constants.deleteUser + userid!.toString()),
        // headers: <String, String>{'Content-Type': 'application/json'},
        // body: jsonEncode(
        //   <String, dynamic>{'userid': userid},
        // ),
      );

      if (response.statusCode == 200) {
        print("User deleted");
        return true;
      } else {
        print("Failed to delete user");
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting account: $e");
      }
      return false;
    }
  }

  Future<List<String>> testRemarks() async {
    try {
      final response = await http.get(Uri.parse(Constants.testRemarks));
      if (response.statusCode == 200) {
        final jsonresponse = jsonDecode(response.body);
        return jsonresponse;
      } else {
        return [];
      }
    } catch (e) {
      print("error in testremark $e");
      return [];
    }
  }
}
