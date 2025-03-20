import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final TextEditingController _remarkController = TextEditingController();

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

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
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
        fetchedAppointments = await Auth().getScheduleAppointments();
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
                    .contains(query.toLowerCase()) ||
                appointment.status!.toLowerCase().contains(query.toLowerCase()))
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
                          : (widget.i == 0 || index == 0)
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredAppointments.length,
                                  itemBuilder: (context, index) {
                                    final appointment =
                                        filteredAppointments[index];
                                    return _buildRowForTotalAppointmentStatus(
                                      appointment.appointment_id,
                                      appointment.clientName,
                                      appointment.medicalTests,
                                      appointment.time,
                                      appointment.date,
                                      appointment.appointment_no,
                                      appointment.mobileno,
                                      appointment.status ?? "not defined",
                                      appointment.rejected_status ??
                                          "not defined",
                                      appointment.address ?? "not defined",
                                    );
                                  })
                              : (index != 3)
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredAppointments.length,
                                      itemBuilder: (context, index) {
                                        final appointment =
                                            filteredAppointments[index];
                                        return Slidable(
                                          endActionPane: ActionPane(
                                            motion: const BehindMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {
                                                  // Add your action for delete

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      bool validate =
                                                          false; // Local state inside the dialog

                                                      return StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            title: const Text(
                                                                'Do you want to reject this appointment?'),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                TextFormField(
                                                                  controller:
                                                                      _remarkController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        "Remark",
                                                                    hintText:
                                                                        "Enter Remark",
                                                                    border:
                                                                        const OutlineInputBorder(),
                                                                    errorText: validate
                                                                        ? "Value Can't Be Empty"
                                                                        : null,
                                                                  ),
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .text,
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  _remarkController
                                                                      .clear();
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    'CANCEL'),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (_remarkController
                                                                      .text
                                                                      .isNotEmpty) {
                                                                    final result = await Auth().rejectAppointment(
                                                                        appointment
                                                                            .appointment_id,
                                                                        _remarkController
                                                                            .text
                                                                            .trim());
                                                                    setState(
                                                                        () {
                                                                      if (result) {
                                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                            content:
                                                                                Text("Appointment rejected successfully")));
                                                                        print(
                                                                            "Delete ${appointment.appointment_id}");
                                                                        Navigator.of(context)
                                                                            .pop(); // Close dialog on success
                                                                        _remarkController
                                                                            .clear();
                                                                      } else {
                                                                        print(
                                                                            "${appointment.appointment_id} not rejected");
                                                                        Navigator.of(context)
                                                                            .pop(); // Close dialog on success
                                                                        _remarkController
                                                                            .clear();
                                                                      }
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      validate =
                                                                          true; // Update UI dynamically
                                                                    });
                                                                  }
                                                                },
                                                                child: const Text(
                                                                    'REJECT'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                icon: Icons.close,
                                                label: 'Reject',
                                              ),
                                            ],
                                          ),
                                          child: _buildRow(
                                            appointment.appointment_id,
                                            appointment.clientName,
                                            appointment.medicalTests,
                                            appointment.time,
                                            appointment.date,
                                            appointment.appointment_no,
                                            appointment.mobileno,
                                            appointment.rejected_status ??
                                                "not defined",
                                            appointment.address ??
                                                "not defined",
                                          ),
                                        );
                                      })
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredAppointments.length,
                                      itemBuilder: (context, index) {
                                        final appointment =
                                            filteredAppointments[index];
                                        return _buildRowForRejectedAppointmentStatus(
                                          appointment.appointment_id,
                                          appointment.clientName,
                                          appointment.medicalTests,
                                          appointment.time,
                                          appointment.date,
                                          appointment.appointment_no,
                                          appointment.mobileno,
                                          appointment.status ?? "not defined",
                                          appointment.rejected_status ?? "b",
                                          appointment.address ?? "not defined",
                                        );
                                      })),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    int id,
    String name,
    String medicalTests,
    String time,
    String date,
    String appointment_no,
    String mobileno,
    String rejectedStatus,
    String address,
  ) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 215, 213, 213),
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
            rejectedStatus == "1"
                ? Text(
                    "High Priority",
                    style: TextStyle(color: Colors.pink),
                  )
                : SizedBox()
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
                  address: address,
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

  Widget _buildRowForTotalAppointmentStatus(
    int id,
    String name,
    String medicalTests,
    String time,
    String date,
    String appointment_no,
    String mobileno,
    String status,
    String rejected_status,
    String address,
  ) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 215, 213, 213),
                  style: BorderStyle.solid))),
      child: ListTile(
        // trailing: IconButton(
        //   onPressed: () {
        //     // here according to status there is no need to show call icon

        //     // _launchDialer(mobileno.toString().trim());
        //   },
        //   icon: const Icon(Icons.call),
        //   color: Colors.green,
        // ),
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
            // below this text i think i should add status of that appointment.
            Text(
              "Status: ${status.trim()}",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),

            rejected_status == "1"
                ? Text(
                    "Rejected",
                    style: TextStyle(color: Colors.pink),
                  )
                : SizedBox()
          ],
        ),
        title: Text(
          name.trim(),
          style: _biggerFont,
        ),
        onTap: () async {
// according to me i think , on tap will not be in use for this module.

          // final result = await Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => AppointmentDetails(
          //         clientName: name,
          //         medicalreports: medicalTests,
          //         date: date,
          //         time: time,
          //         appointment_id: id,
          //         appointment_no: appointment_no,
          //       ),
          //     ));

          // print("result:of backpress1$result");

          // if (result == "refresh") {
          //   setState(() {
          //     _fetchAppointments();
          //   }); // Reload data when returning
          //   print("result:of backpress2$result");
          // }
        },
      ),
    );
  }

  Widget _buildRowForRejectedAppointmentStatus(
    int id,
    String name,
    String medicalTests,
    String time,
    String date,
    String appointment_no,
    String mobileno,
    String status,
    String rejected_status,
    String address,
  ) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Color.fromARGB(255, 215, 213, 213),
                  style: BorderStyle.solid))),
      child: ListTile(
        // trailing: IconButton(
        //   onPressed: () {
        //     // here according to status there is no need to show call icon

        //     // _launchDialer(mobileno.toString().trim());
        //   },
        //   icon: const Icon(Icons.call),
        //   color: Colors.green,
        // ),
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
            // below this text i think i should add status of that appointment.

            rejected_status == "1"
                ? Text(
                    "Rejected",
                    style: TextStyle(color: Colors.pink),
                  )
                : SizedBox()
          ],
        ),
        title: Text(
          name.trim(),
          style: _biggerFont,
        ),
        onTap: () async {
// according to me i think , on tap will not be in use for this module.

          // final result = await Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => AppointmentDetails(
          //         clientName: name,
          //         medicalreports: medicalTests,
          //         date: date,
          //         time: time,
          //         appointment_id: id,
          //         appointment_no: appointment_no,
          //       ),
          //     ));

          // print("result:of backpress1$result");

          // if (result == "refresh") {
          //   setState(() {
          //     _fetchAppointments();
          //   }); // Reload data when returning
          //   print("result:of backpress2$result");
          // }
        },
      ),
    );
  }
}
