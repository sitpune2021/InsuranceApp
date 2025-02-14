import 'package:animate_do/animate_do.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:insurance/appointment_details/appointment_details.dart';
import 'package:insurance/appointment_screen/appointment_screen.dart';
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalAppCount = 0;
  int todaysAppCount = 0;
  int scheduleCount = 0;
  int pendingCount = 0;

  String date = "13/2/2025";
  String medicalTests = "CT ,MT, HBA1C,PET ,MRI ";
  String time = "03:05:47";
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  List<List<String>> services = [
    [
      'Total Appointments',
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'
    ],
    [
      "Today's Appointment",
      'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-plumber-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'
    ],
    [
      'Schedule Appointment',
      'https://img.icons8.com/external-wanicon-flat-wanicon/2x/external-multimeter-car-service-wanicon-flat-wanicon.png'
    ],
    [
      'Pending Appointment',
      'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-painter-male-occupation-avatar-itim2101-flat-itim2101.png'
    ],
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(198, 201, 254, 1),
        title: const Text("Insurance"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu Icon',
          onPressed: () {},
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                  child: Container(
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
                          delay: Duration(milliseconds: 500 * index),
                          child: GestureDetector(
                            child: serviceContainer(
                              services[index][1],
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
                FutureBuilder<List<Appointment>>(
                  future: Auth().getTotalAppointments(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                                );
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

  Widget serviceContainer(String image, String name, int index) {
    return GestureDetector(
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
                    color: Colors.green),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int id, String name, String medicalTests, String time,
      String date, String appointment_no, String mobileno) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 215, 213, 213),
                  style: BorderStyle.solid))),
      child: ListTile(
        trailing: IconButton(
          onPressed: () {
            _launchDialer(mobileno);
          },
          icon: const Icon(Icons.call),
          color: Colors.green,
        ),
        leading: const CircleAvatar(
          child: Icon(
            Icons.person,
            color: Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${medicalTests.trim()}",
              style: TextStyle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "${date.trim()}",
              style: TextStyle(),
              maxLines: 1,
            ),
          ],
        ),
        title: Text(
          name.toString().trim(),
          style: _biggerFont,
        ),
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
