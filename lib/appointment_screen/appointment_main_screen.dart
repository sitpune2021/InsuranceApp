import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:insurance/appointment_details/appointment_details.dart';
import 'package:insurance/appointment_screen/appointment_screen.dart';
import 'package:insurance/appointment_screen/completed_appointment_details/completed_appointment_details.dart';
import 'package:insurance/appointment_screen/model/appointment.dart';
import 'package:insurance/services/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentMainScreen extends StatefulWidget {
  const AppointmentMainScreen({super.key});

  @override
  State<AppointmentMainScreen> createState() => _AppointmentMainScreenState();
}

class _AppointmentMainScreenState extends State<AppointmentMainScreen> {
  List<Appointment> appointments = [];

  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  List<Appointment> filteredAppointments = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Call the asynchronous method here
    _initializeApp();
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
    await _fetchAppointments();
    // If you need to get preferences as well
  }

// Function to fetch appointments and update state
  Future<void> _fetchAppointments() async {
    try {
      // final fetchedAppointments = await Auth().getTotalAppointments();
      // final fetchedAppointments = index == 1
      //     ? await Auth().getTodaysAppointments()
      //     : await Auth().getTotalAppointments();
      List<Appointment> fetchedAppointments = [];

      // if (index == 0) {
      fetchedAppointments = await Auth().getCompletedAppointments();
      // } else if (index == 1) {
      //   fetchedAppointments = await Auth().getTodaysAppointments();
      // } else if (index == 2) {
      //   fetchedAppointments = await Auth().getScheduleAppointments();
      // } else if (index == 3) {
      //   fetchedAppointments = await Auth().getPendingAppointments();
      // }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 5,
        shadowColor: Colors.grey,
        backgroundColor: const Color(0xFF546AE4), // Blue background
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Completed Appointments",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Rounded border
              ),
              child: TextField(
                onChanged: _filterAppointments,
                decoration: const InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
        toolbarHeight: 150, // Increased height to fit search bar
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FadeInUp(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: filteredAppointments.isEmpty
                      ? const Center(
                          child: const Text(
                            "No Appointments available",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.pink),
                          ),
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
    );
  }

  Widget _buildRow(int id, String name, String medicalTests, String time,
      String date, String appointment_no, String mobileno) {
    return GestureDetector(
      onTap: () {
        print(
            "*******************completed appointment appointment id $id *******************");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentViewerScreen(
              appointmentId: id, // Replace with the actual appointment ID
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                child: const CircleAvatar(
                  backgroundColor: Color(0xFF546AE4),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toString().trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      date.toString().trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medicalTests.toString().trim(),
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
}
