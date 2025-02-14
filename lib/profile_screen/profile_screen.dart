import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:insurance/login_screen/login_screen.dart';
import 'package:insurance/session/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCardScreen extends StatefulWidget {
  final String name;
  final String mobileno;

  const ProfileCardScreen({
    super.key,
    required this.name,
    required this.mobileno,
  });

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  late String _name;
  late String _mobileNo;
  late String _imageUrl =
      "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg?cs=srgb&dl=pexels-anjana-c-169994-674010.jpg&fm=jpg";
  File? _newImage; // Store the new image file

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _mobileNo = widget.mobileno;
    // _imageUrl = widget.image;
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? "Guest";
      _mobileNo = prefs.getString('userMobile') ?? "Not Available";
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImage = File(pickedFile.path);
      });

      // Upload the selected image
      await _uploadImage(_newImage!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final uri = Uri.parse(
        "http://43.205.22.150:5000/upload"); // Replace with your upload URL
    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // Parameter name expected by your server
        imageFile.path,
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Handle success
        final responseBody = await response.stream.bytesToString();
        print("Upload successful: $responseBody");
      } else {
        // Handle failure
        Fluttertoast.showToast(
          msg: "Uplaod failed check internet connection",
          toastLength: Toast.LENGTH_SHORT, // or Toast.LENGTH_LONG
          gravity: ToastGravity
              .BOTTOM, // position of the toast (TOP, BOTTOM, CENTER)
          timeInSecForIosWeb: 1, // iOS/ Web duration
          backgroundColor: Colors.black, // background color of toast
          textColor: Colors.white, // text color
          fontSize: 16.0, // font size
        );
        print("Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }
// class ProfileCardScreen extends StatelessWidget {
//   final String name;
//   final String mobileno;
//   final String image;

//   const ProfileCardScreen(
//       {super.key,
//       required this.name,
//       required this.mobileno,
//       required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Your Profile"),
          backgroundColor: const Color.fromRGBO(198, 201, 254, 1),
        ),
        body: Column(
          children: [
            // The scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: FadeInUp(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Card(
                        color: Colors.white,
                        elevation: 3,
                        margin: EdgeInsets.zero, // Remove default margin
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16.0), // Adjust padding for uniform spacing
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment
                                .stretch, // Center-align horizontally
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer circle
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue[50],
                                      border: Border.all(
                                          color: Colors.green, width: 3),
                                    ),
                                  ),
                                  // Icon
                                  // const Icon(
                                  //   Icons.person,
                                  //   size: 60,
                                  //   color: Colors.blueGrey,
                                  // ),
                                  ClipOval(
                                    child: Stack(
                                      children: [
                                        // Image.network(
                                        //   "http://43.205.22.150:5000/users/$_imageUrl",
                                        //   width: 96,
                                        //   height: 96,
                                        //   fit: BoxFit.cover,
                                        //   errorBuilder:
                                        //       (context, error, stackTrace) {
                                        // return
                                        Container(
                                          width: 96,
                                          height: 96,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue[50],
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.blueGrey,
                                          ),
                                          //   );
                                          // },
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              // _pickImage(); // Call the function to pick an image
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.blue,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height:
                                      16), // Spacing between circle and content
                              Text(
                                _name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Mob No: $_mobileNo",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // const Row(
                              //   mainAxisSize:
                              //       MainAxisSize.min, // Align items closely
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Icon(
                              //       Icons.star,
                              //       color: Colors.blue,
                              //       size: 18,
                              //     ),
                              //     SizedBox(width: 8),
                              //     Text(
                              //       "Assistant",
                              //       style: TextStyle(
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.bold,
                              //         color: Color.fromARGB(255, 100, 97, 97),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Profile Information Section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.info, color: Colors.blue),
                          title: const Text("Basic Profile Information"),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          // onTap: () {
                          //   // Handle tap
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const BasicProfileScreen()),
                          //   );
                          // },
                          onTap: () {
                            // Future.delayed(const Duration(milliseconds: 200), () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => const MyKycScreen()),
                            //   );
                            // });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),

                      // KYC Section with Video Icon and Complete KYC Text
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "KYC",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // KYC Card
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading:
                              const Icon(Icons.credit_card, color: Colors.blue),
                          title: const Text("Identity Details"),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            // Handle tap
                          },
                        ),
                      ),
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.account_balance,
                              color: Colors.blue),
                          title: const Text("Bank Details"),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () {
                            // Handle tap
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 2.0),
                          child: Text(
                            "Exit",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      //Delete My Account
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.blue),
                          title: const Text("Delete Account"),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                          ),
                          onTap: () {
                            // Handle tap
                            // showLogoutDialog(context);
                          },
                        ),
                      ),

                      // Log Out Button at the Bottom
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.logout, color: Colors.blue),
                          title: const Text("Log Out"),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize.min,
                          ),
                          onTap: () {
                            // Handle tap
                            showLogoutDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

Future<void> showLogoutDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            child: const Text('Log out'),
            onPressed: () async {
              Session.logout();
              Navigator.of(context).pop(); // Dismiss the dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      );
    },
  );
}
