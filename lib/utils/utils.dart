import 'package:connectivity_plus/connectivity_plus.dart';

class Utils {
  static Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to a network
    } else {
      return false; // No connection
    }
  }
}
