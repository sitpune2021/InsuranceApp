import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:insurance/appointment_details/appointment_details.dart';
import 'package:insurance/appointment_screen/appointment_screen.dart';
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime now = DateTime.now();
  int totalAppCount = 0;
  int todaysAppCount = 0;
  int scheduleCount = 0;
  int pendingCount = 0;

  String date = "13/2/2025";
  String medicalTests = "CT ,MT, HBA1C,PET ,MRI ";
  String time = "03:05:47";
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  List<List<String>> services = [
    ['Total Appointments', '0xFFD64A45'], // Corrected hex code
    ["Today's Appointment", '0xFFFEAD4A'],
    ['Assigned Appointment', '0xFF00DDED'],
    ['Rejected Appointment', '0xFF495EDE'],
  ];

  @override
  void initState() {
    super.initState();
    count();
  }

  void count() {
    setState(() {
      totalappointCount();
      todayappointCount();
      scheduleappointCount();
      pendingappointCount();
    });
  }

  Future<void> _launchDialer(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not launch $uri";
    }
  }

  Future<void> totalappointCount() async {
    List<Appointment> totalappc = await Auth().getTotalAppointments();
    print("$totalappc totalAppCount list");
    setState(() {
      totalAppCount = totalappc.length;
    });
    print("$totalAppCount totalAppCount");
  }

  Future<void> todayappointCount() async {
    List<Appointment> todaysAppC = await Auth().getTodaysAppointments();
    setState(() {
      todaysAppCount = todaysAppC.length;
    });
    print("$todaysAppCount totalAppCount");
  }

  Future<void> scheduleappointCount() async {
    List<Appointment> scheduleAppC = await Auth().getScheduleAppointments();
    setState(() {
      scheduleCount = scheduleAppC.length;
    });
    print("$scheduleCount totalAppCount");
  }

  Future<void> pendingappointCount() async {
    List<Appointment> pendingAppC = await Auth().getPendingAppointments();
    setState(() {
      pendingCount = pendingAppC.length;
    });
    print("$todaysAppCount totalAppCount");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: const Color.fromRGBO(198, 201, 254, 1),
      //   title: const Text("Insurance"),
      //   leading: Padding(
      //     padding: const EdgeInsets.only(
      //         top: 4, bottom: 4, left: 4), // Adjust top and bottom padding
      //     child: Container(
      //       width: 50,
      //       decoration: const BoxDecoration(
      //         image: DecorationImage(
      //           image: AssetImage("assets/images/logo.png"),
      //           fit: BoxFit.fill,
      //         ),
      //       ),
      //     ),
      //   ),
      //   leadingWidth: 50,
      // ),
      body: RefreshIndicator(
        // backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05), // 5% padding
                // color: Colors.blue,
                decoration: BoxDecoration(
                  color: const Color(0xFF546AE4),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                        screenWidth * 0.1), // 10% of screen width
                    bottomRight: Radius.circular(screenWidth * 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Insurance",
                            style: TextStyle(
                                fontSize:
                                    screenWidth * 0.05, // Scalable text size
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Hello,\n${DateFormat.yMMMEd().format(now)}",
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.05, // Scalable text size
                              color: Colors.white,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02), // Add spacing
                    Image.asset(
                      "assets/images/dash.png",
                      height:
                          screenHeight * 0.3, // Adjust based on screen height
                      width: screenWidth * 0.4, // 40% of screen width
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.white,
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: services.length,
                          itemBuilder: (BuildContext context, int index) {
                            return FadeInUp(
                              delay: Duration(milliseconds: 200 * index),
                              child: GestureDetector(
                                child: serviceContainer(
                                  int.tryParse(services[index][1])!,
                                  services[index][0],
                                  index,
                                ),
                                onTap: () async {
                                  SharedPreferences pref =
                                      await SharedPreferences.getInstance();
                                  pref.setInt("page", index);

                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AppointmentScreen(
                                          i: 1,
                                        ),
                                      ));

                                  if (result == "refresh") {
                                    setState(() {
                                      print("backprede: refreshed ");
                                      count();
                                      Auth().getTotalAppointments();
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "List of Appointments",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    FutureBuilder<List<Appointment>>(
                      future: Auth().getScheduleAppointments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasData) {
                          int length;
                          if (snapshot.data!.length < 5) {
                            length = snapshot.data!.length;
                          } else {
                            length = 5;
                          }
                          return length == 0
                              ? const Text(
                                  "No Appointments available",
                                  style: TextStyle(color: Colors.pink),
                                )
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: length,
                                  itemBuilder: (context, index) {
                                    final appointment = snapshot.data?[index];
                                    return _buildRow(
                                        appointment!.appointment_id,
                                        appointment.clientName,
                                        appointment.medicalTests,
                                        appointment.time,
                                        appointment.date,
                                        appointment.appointment_no,
                                        appointment.mobileno,
                                        appointment.address ?? "not defined");
                                  });
                        }
                        return const Center(
                          child: Text("No appointments available."),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Refreshing counts
    count();
    //calling this to rebuild the tree.
    setState(() {});
  }

  Widget serviceContainer(int image, String name, int index) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(image),
          border: Border.all(
            color: Colors.blue.withOpacity(0),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image.network(image, height: 45),
            SizedBox(
              height: 45,
              child: Text(
                _getCountForIndex(index),
                style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int id, String name, String medicalTests, String time,
      String date, String appointment_no, String mobileno, String address) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetails(
                clientName: name,
                medicalreports: medicalTests,
                date: date,
                time: time,
                appointment_id: id,
                appointment_no: appointment_no,
                address: address,
              ),
            ));

        if (result == "refresh") {
          setState(() {
            print("backprede: refreshed ");
            count();
            Auth().getTotalAppointments();
          }); // Reload data when returning
          print("result:of backpress2$result");
        }
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                // decoration: BoxDecoration(
                //     border: Border.all(
                //         color: Colors.blue, width: 2, style: BorderStyle.solid),
                //     borderRadius: BorderRadius.circular(50)),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF546AE4),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medicalTests,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _launchDialer(mobileno),
                icon: const Icon(Icons.call, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCountForIndex(int index) {
    switch (index) {
      case 0:
        return totalAppCount.toString();
      case 1:
        return todaysAppCount.toString();
      case 2:
        return scheduleCount.toString();
      case 3:
        return pendingCount.toString();
      default:
        return "0";
    }
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // Connected to a network
    } else {
      return false; // No connection
    }
  }
}
