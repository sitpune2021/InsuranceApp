import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:insurance/appointment_details/appointment_details.dart';
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentScreen extends StatefulWidget {
  final int? i;
  const AppointmentScreen({
    this.i,
    super.key,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Appointment> appointments = [];
  Object? index;

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  List<Appointment> filteredAppointments = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Call the asynchronous method here
    _initializeApp();
    setState(() {});
  }

  Future<void> _launchDialer(String number) async {
    final Uri uri = Uri(scheme: "tel", path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw "Could not launch $uri";
    }
  }

  // Separate method to handle async initialization
  Future<void> _initializeApp() async {
    await getpref();
    await _fetchAppointments();
    // If you need to get preferences as well
  }

  Future<void> getpref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    index = prefs.get("page");
    print("index$index");
  }

// Function to fetch appointments and update state
  Future<void> _fetchAppointments() async {
    try {
      // final fetchedAppointments = await Auth().getTotalAppointments();
      // final fetchedAppointments = index == 1
      //     ? await Auth().getTodaysAppointments()
      //     : await Auth().getTotalAppointments();
      List<Appointment> fetchedAppointments = [];
      if (widget.i == 0) {
        fetchedAppointments = await Auth().getTotalAppointments();
      } else if (widget.i != 0) {
        if (index == 0) {
          fetchedAppointments = await Auth().getTotalAppointments();
        } else if (index == 1) {
          fetchedAppointments = await Auth().getTodaysAppointments();
        } else if (index == 2) {
          fetchedAppointments = await Auth().getScheduleAppointments();
        } else if (index == 3) {
          fetchedAppointments = await Auth().getPendingAppointments();
        }
      }

      // descending the list
      // List<Appointment> descAppointments = [];

      // for (int i = fetchedAppointments.length - 1; i >= 0; i--) {
      //   descAppointments.add(fetchedAppointments[i]);
      // }
      setState(() {
        appointments = fetchedAppointments;
        filteredAppointments = appointments; // Initialize with all data
      });
      print("Fetched Appointments: $appointments"); // Debugging
    } catch (e) {
      // Handle errors if the fetching fails
      print("Error fetching appointments: $e");
    }
  }

  void _filterAppointments(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAppointments = appointments;
      } else {
        filteredAppointments = appointments
            .where((appointment) =>
                appointment.clientName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                appointment.medicalTests
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _refreshData() async {
    // Refresh the appointments
    _fetchAppointments();
    // Call setState to rebuild the widget tree with updated data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "refresh");
        print("backpredeee");
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(198, 201, 254, 1),
          title: const Text("Appointments"),
        ),
        body: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FadeInUp(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      onChanged: _filterAppointments,
                      decoration: InputDecoration(
                        labelText: "Search",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filteredAppointments.isEmpty
                        ? const Text(
                            "No Appointments available",
                            style: TextStyle(color: Colors.pink),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = filteredAppointments[index];
                              return _buildRow(
                                appointment.appointment_id,
                                appointment.clientName,
                                appointment.medicalTests,
                                appointment.time,
                                appointment.date,
                                appointment.appointment_no,
                                appointment.mobileno,
                              );
                            }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(int id, String name, String medicalTests, String time,
      String date, String appointment_no, String mobileno) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: const Color.fromARGB(255, 215, 213, 213),
                  style: BorderStyle.solid))),
      child: ListTile(
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       onPressed: () {},
        //       icon: const Icon(Icons.call),
        //       color: Colors.green,
        //     ),
        //     IconButton(
        //       onPressed: () {},
        //       icon: const Icon(Icons.keyboard_double_arrow_right_rounded),
        //       color: Colors.grey,
        //     ),
        //   ],
        // ),
        trailing: IconButton(
          onPressed: () {
            _launchDialer(mobileno.toString().trim());
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
              medicalTests.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              date.trim(),
              maxLines: 1,
            ),
          ],
        ),
        title: Text(
          name.trim(),
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

          print("result:of backpress1$result");

          if (result == "refresh") {
            setState(() {
              _fetchAppointments();
            }); // Reload data when returning
            print("result:of backpress2$result");
          }
        },
      ),
    );
  }
}
