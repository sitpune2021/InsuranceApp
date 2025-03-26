import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance/appointment_details/test.dart';
import 'package:insurance/appointment_screen/appointment_screen.dart';
import 'package:insurance/appointment_screen/model/test_remark.dart';
import 'package:insurance/camera_screen/camera_screen.dart';
import 'package:insurance/utils/constants.dart';
import 'package:location/location.dart' as loc;
import 'package:map_camera_flutter/map_camera_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:video_player/video_player.dart';

class AppointmentDetails extends StatefulWidget {
  final int appointment_id;
  final String clientName;
  final String medicalreports;
  final String date;
  final String time;
  final String appointment_no;
  final String address;
  const AppointmentDetails(
      {super.key,
      required this.clientName,
      required this.medicalreports,
      required this.date,
      required this.time,
      required this.appointment_id,
      required this.appointment_no,
      required this.address});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  List<String> _remarks = []; // List to store remarks from API
  Object? index;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _imageloading = false;
  bool _isLoading = false;
  bool isSelected = false;
  File? _image;
  File? _vedio;
  bool _isVedioLoding = false;
  VideoPlayerController? _videoController;
  double videoContainerWidth = double.infinity;

  late TextEditingController _nameController;
  late TextEditingController _medicalreportsController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  final _descriptionController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  TestStatus? _testStatus;
  bool? urineCheck = false;
  bool? ecgCheck = false;
  bool? bloodCheck = false;
  List<File> _images = []; // List to store selected images
  bool _imageLoading = false; // Loading state

  String? _selectedRemark;

  Future<void> fetchRemarks() async {
    final url = Uri.parse(Constants.testRemarks); // Replace with actual API URL
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _remarks = data.map((json) => json['remark'].toString()).toList();
          // if (_remarks.isNotEmpty) {
          //   _selectedRemark = _remarks.first; // Set default selection
          // }
        });
      } else {
        print("Failed to load remarks: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching remarks: $error");
    }
  }

  // Get address from latitude/longitude
  Future<String> _getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.locality}, "
            "${place.administrativeArea}, ${place.country}";
      }
      return "Address not found";
    } catch (e) {
      debugPrint("Error getting address: $e");
      return "Error: $e";
    }
  }

  Future<void> _sendData() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload an image.")),
      );
      return;
    } else if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Description is empty")),
      );
      return;
    } else if (_testStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Test status is empty")),
      );
      return;
    }
    setState(() {
      _isLoading = true; // Start the loader
    });
    try {
      final location = loc.Location();
      final locationData = await location.getLocation();
      final latitude = locationData.latitude;
      final longitude = locationData.longitude;

      final uri =
          Uri.parse(Constants.addAppointmentsubmit); // Update with your API
      final request = http.MultipartRequest('POST', uri);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setInt("page", );
      int? assistant_id = prefs.getInt("id");
      // **Add multiple images to the request**
      for (var image in _images) {
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));
      }
      request.fields['description'] = _descriptionController.text;
      request.fields['appointment_nos'] = widget.appointment_no;
      request.fields['assistant_id'] = assistant_id.toString();

      request.fields['latitude'] = latitude?.toString() ?? '';
      request.fields['longitude'] = longitude?.toString() ?? '';

      if (_vedio != null) {
        final videoFile = File(_vedio!.path);

        if (await videoFile.exists()) {
          print("Video File Exists: ${_vedio!.path}"); // Debugging
          request.files.add(
            await http.MultipartFile.fromPath('video', _vedio!.path),
          );
        } else {
          print("Video file does not exist at ${_vedio!.path}");
        }
      }

      request.fields['urine_test'] = urineCheck.toString();
      request.fields['ecg_test'] = ecgCheck.toString();
      request.fields['blood_test'] = bloodCheck.toString();
      request.fields['test_completed'] = _testStatus.toString();
      // request.fields['reason'] = '';
      request.fields['reason'] = _selectedRemark ?? "not selected";

      final response = await request.send();

      if (response.statusCode == 200) {
        final http.Response response = await http.put(
          Uri.parse(Constants.updateStatusOfSubmittedAppointment +
              widget.appointment_id.toString()),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          print("updateStatusOfSubmittedAppointment ${response.body}");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data submitted successfully!")),
        );
        // Pop and send refresh signal
        Navigator.of(context).pop("refresh");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to submit data. Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    final pickedVideo =
        await ImagePicker().pickVideo(source: ImageSource.camera);

    if (pickedVideo != null) {
      setState(() {
        _isVedioLoding = true;
      });

      _vedio = File(pickedVideo.path);
      print("vedio${_vedio!.path}");
      _videoController = VideoPlayerController.file(_vedio!)
        ..initialize().then((_) {
          setState(() {
            _isVedioLoding = false;
            // _videoController!.play();
          });
        });
    } else {
      setState(() {
        _isVedioLoding = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      setState(() {
        _imageloading = true;
      });

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final imageBytes = await imageFile.readAsBytes();

        // Decode the captured image
        img.Image capturedImage = img.decodeImage(imageBytes)!;

        // Get current location (latitude and longitude)
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Get address from latitude and longitude
        List<Placemark> placemarks = await GeocodingPlatform.instance!
            .placemarkFromCoordinates(position.latitude, position.longitude);
        Placemark place = placemarks.first;

        final geotagText =
            "Latitude: ${position.latitude}\nLongitude: ${position.longitude}\nAddress: ${place.street}, ${place.locality}, ${place.country}";

        // Calculate dimensions for the map and text area
        final mapWidth = capturedImage.width ~/ 2;
        final mapHeight = (mapWidth * 150) ~/ 300;
        final textBoxWidth = capturedImage.width ~/ 2;
        final textBoxHeight = mapHeight.toInt();

        // Construct the Google Maps static URL for the map image
        final mapUrl =
            "https://maps.googleapis.com/maps/api/staticmap?center=${position.latitude},${position.longitude}&zoom=15&size=${mapWidth}x${mapHeight.toInt()}&markers=color:red%7Clabel:C%7C${position.latitude},${position.longitude}&key=AIzaSyD9XZBYlnwfrKQ1ZK-EUxJtFePKXW_1sfE";

        // Fetch the map image
        final response = await http.get(Uri.parse(mapUrl));
        if (response.statusCode == 200) {
          img.Image mapImage =
              img.decodeImage(Uint8List.fromList(response.bodyBytes))!;

          // Prepare text for geotag info
          final now = DateTime.now();
          final dateTimeStr =
              "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}";
          final geotagTextWithDate =
              "$geotagText\n\nDate & Time:\n$dateTimeStr";

          // Create a new canvas to hold the original photo, map, and text
          final extendedImage = img.Image(
            capturedImage.width,
            capturedImage.height + mapHeight.toInt(),
          );

          // Place the original image
          img.copyInto(extendedImage, capturedImage, dstX: 0, dstY: 0);

          // Place the map in the bottom left
          img.copyInto(extendedImage, mapImage,
              dstX: 0, dstY: capturedImage.height);

          // Draw the black background for the text box
          img.fillRect(
            extendedImage,
            mapWidth,
            capturedImage.height,
            capturedImage.width,
            capturedImage.height + mapHeight.toInt(),
            img.getColor(0, 0, 0, 255),
          );

          // Add the geotag text in the black box
          img.drawString(
            extendedImage,
            img.arial_48,
            mapWidth + 10,
            capturedImage.height + 10,
            geotagTextWithDate,
            color: img.getColor(255, 255, 255),
          );

          // Save the updated image
          final updatedImageBytes = img.encodeJpg(extendedImage);
          final updatedImageFile = File(pickedFile.path)
            ..writeAsBytesSync(updatedImageBytes);

          // Add the new image to the list
          setState(() {
            _images.add(updatedImageFile);
            _imageloading = false;
          });
        } else {
          debugPrint("Failed to load map image: ${response.statusCode}");
          setState(() {
            _imageloading = false;
          });
        }
      } else {
        setState(() {
          _imageloading = false;
        });
      }
    } catch (e) {
      debugPrint("Error capturing and saving photo: $e");
      setState(() {
        _imageloading = false;
      });
    }
  }

  /// Function to remove an image from the list
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize the TextEditingController with the clientName from the widget
    fetchRemarks(); // Fetch remarks when the widget initializes
    _nameController = TextEditingController(text: "Name: ${widget.clientName}");
    _medicalreportsController =
        TextEditingController(text: "Lab Reports: ${widget.medicalreports}");
    addressController =
        TextEditingController(text: "Address: ${widget.address}");
    _dateController = TextEditingController(text: "Date: ${widget.date}");
    _timeController = TextEditingController(text: "Time: ${widget.time}");
    help().then((_) {
      if (mounted) {
        setState(() {
          // Assign initialization future for camera
          _initializeControllerFuture = _controller.initialize();
        });
      }
    });
  }

  Future<void> help() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.ultraHigh,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _medicalreportsController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _videoController?.dispose();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 5,
        shadowColor: Colors.grey,
        backgroundColor: const Color(0xFF546AE4),
        title: const Text(
          "Appointment Detail",
          style: TextStyle(color: Colors.white),
        ),
        toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.all(12), // Padding for better appearance
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          Colors.grey), // Border similar to OutlineInputBorder
                  borderRadius: BorderRadius.circular(
                      4), // Rounded corners like TextField
                ),
                child: Text(
                  "Medical Reports:\n${widget.medicalreports}",
                  style: const TextStyle(
                      fontSize: 16), // Adjust text style for better readability
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.all(12), // Padding for better appearance
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          Colors.grey), // Border similar to OutlineInputBorder
                  borderRadius: BorderRadius.circular(
                      4), // Rounded corners like TextField
                ),
                child: Text(
                  "Address:\n${widget.address}",
                  style: const TextStyle(
                      fontSize: 16), // Adjust text style for better readability
                ),
              ),
              // TextField(
              //   readOnly: true,
              //   controller: _medicalreportsController,
              //   decoration: const InputDecoration(
              //     labelText: "Reports",
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 16),
              // DropdownButtonFormField<String>(
              //   decoration: const InputDecoration(
              //     labelText: "Date",
              //     border: OutlineInputBorder(),
              //   ),
              //   items: const [
              //     DropdownMenuItem(value: "Family", child: Text("Family")),
              //     DropdownMenuItem(value: "Self", child: Text("Self")),
              //     DropdownMenuItem(value: "Other", child: Text("Other")),
              //   ],
              //   onChanged: (value) {
              //     // Handle dropdown change
              //   },
              // ),
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // TextField(
              //   readOnly: true,
              //   controller: _timeController,
              //   decoration: const InputDecoration(
              //     labelText: "Time",
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.phone,
              // ),
              // const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Enter Description",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              Card(
                margin: const EdgeInsets.all(0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4), // Matches the TextField border
                  side: const BorderSide(
                      color: Colors.black54,
                      width: 1), // Border to match TextField
                ),
                elevation: 0, // Keep it flat like the TextField
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Urine Test',
                          style: TextStyle(
                            fontSize: 16.0,
                            color:
                                Colors.black87, // Match TextField label color
                          ),
                        ),
                      ),
                      Checkbox(
                        value: urineCheck,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                4)), // Square checkbox like Material 3
                        onChanged: (bool? newValue) {
                          setState(() {
                            urineCheck = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.all(0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4), // Matches the TextField border
                  side: const BorderSide(
                      color: Colors.black54,
                      width: 1), // Border to match TextField
                ),
                elevation: 0, // Keep it flat like the TextField
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Blood Test',
                          style: TextStyle(
                            fontSize: 16.0,
                            color:
                                Colors.black87, // Match TextField label color
                          ),
                        ),
                      ),
                      Checkbox(
                        value: bloodCheck,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                4)), // Square checkbox like Material 3
                        onChanged: (bool? newValue) {
                          setState(() {
                            bloodCheck = newValue;
                            print("Checkbox $bloodCheck");
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.all(0),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(4), // Matches the TextField border
                  side: const BorderSide(
                      color: Colors.black54,
                      width: 1), // Border to match TextField
                ),
                elevation: 0, // Keep it flat like the TextField
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'ECG',
                          style: TextStyle(
                            fontSize: 16.0,
                            color:
                                Colors.black87, // Match TextField label color
                          ),
                        ),
                      ),
                      Checkbox(
                        value: ecgCheck,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                4)), // Square checkbox like Material 3
                        onChanged: (bool? newValue) {
                          setState(() {
                            ecgCheck = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // radio buttons

              RadioListTile<TestStatus>(
                  contentPadding: const EdgeInsets.all(0),
                  value: TestStatus.completed,
                  groupValue: _testStatus,
                  title: const Text("Completed"),
                  onChanged: (val) {
                    setState(() {
                      if (urineCheck != false &&
                          ecgCheck != false &&
                          bloodCheck != false) {
                        _testStatus = val;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Please check all checkboxes to make test status completed")));
                      }
                    });
                  }),
              RadioListTile<TestStatus>(
                  contentPadding: const EdgeInsets.all(0),
                  value: TestStatus.notCompleted,
                  title: const Text("Not Completed"),
                  groupValue: _testStatus,
                  onChanged: (val) {
                    setState(() {
                      _testStatus = val;
                      print(_testStatus);
                    });
                  }),
              const SizedBox(
                height: 8,
              ),

              _testStatus == TestStatus.notCompleted
                  ? Column(
                      children: [
                        DropdownButtonFormField<String>(
                          dropdownColor: Colors.white,
                          decoration: const InputDecoration(
                            labelText: "Remark",
                            border: OutlineInputBorder(),
                          ),

                          value: _selectedRemark, // Selected value
                          items: _remarks.map((String remark) {
                            return DropdownMenuItem<String>(
                              value: remark,
                              child: Text(
                                remark,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRemark = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox(height: 1),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage, // Function to pick multiple images
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(
                        child: _imageloading
                            ? const CircularProgressIndicator()
                            : _images.isEmpty
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file,
                                          size: 40, color: Colors.blue),
                                      SizedBox(height: 8),
                                      Text(
                                        "Upload your images",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : _imageGrid(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _images.isEmpty
                      ? const Text(
                          "Please upload at least one image",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : const Text(
                          "Images selected",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                  const SizedBox(height: 24),
                ],
              ),

// for vedio
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Center(
                    child: _isVedioLoding
                        ? const CircularProgressIndicator()
                        : _vedio == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file,
                                      size: 40, color: Colors.blue),
                                  SizedBox(height: 8),
                                  Text(
                                    "Upload your video",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  children: [
                                    if (_vedio !=
                                        null) // Show video only if it's selected
                                      Transform.rotate(
                                        angle: 90 *
                                            3.1415926535 /
                                            180, // Convert degrees to radians
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 500,
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width: _videoController!
                                                  .value.size.width,
                                              height: _videoController!
                                                  .value.size.height,
                                              child: VideoPlayer(
                                                  _videoController!),
                                            ),
                                          ),
                                        ),
                                      ),

                                    // Delete button (Only visible when video exists)
                                    if (_vedio != null)
                                      Positioned(
                                        top: 0,
                                        right: 10,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _vedio = null;
                                              _videoController
                                                  ?.dispose(); // Dispose the controller
                                              _videoController = null;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Colors.red.withOpacity(0.8),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.close,
                                                size: 16, color: Colors.white),
                                          ),
                                        ),
                                      ),

                                    // Play button (Only visible when video exists)
                                    if (_vedio != null)
                                      Positioned(
                                        top: 50,
                                        left:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                50,
                                        child: IconButton(
                                          icon: const Icon(Icons.play_circle,
                                              size: 32),
                                          onPressed: () {
                                            _videoController!.play();
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              _vedio == null
                  ? const Text(
                      "Please upload a valid video",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  : const Text(
                      "Video selected",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
              const SizedBox(height: 24),

// finished for vedio.

              GestureDetector(
                  onTap: _sendData,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      // gradient: const LinearGradient(colors: [
                      //   Color.fromRGBO(143, 148, 251, 1),
                      //   Color.fromRGBO(143, 148, 251, .6),
                      // ]),
                      color: const Color(0xFF546AE4),
                    ),
                    child: Center(
                      child: _isLoading
                          ? Center(
                              child: Container(
                                child: const CircularProgressIndicator(),
                              ),
                            )
                          : const Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  )),
            ])),
      ),
    );
  }

  /// Function to display selected images in a Grid
  Widget _imageGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Display 3 images in a row
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Image.file(_images[index], fit: BoxFit.cover),
                Positioned(
                  top: 0,
                  right: 50,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withOpacity(0.8),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum TestStatus { completed, notCompleted }
