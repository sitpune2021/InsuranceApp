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
  const AppointmentDetails(
      {super.key,
      required this.clientName,
      required this.medicalreports,
      required this.date,
      required this.time,
      required this.appointment_id,
      required this.appointment_no});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
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
  final TextEditingController addressController = TextEditingController();
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

  // Capture, annotate, and save to gallery
// Capture, annotate, and save to gallery

  Future<void> _captureAndSave() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Take the picture
      final xFile = await _controller.takePicture();

      // Load the captured image into memory
      final byteData = await File(xFile.path).readAsBytes();
      final imageBytes = Uint8List.fromList(byteData);

      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Convert coordinates to an address
      final address = await _getAddressFromPosition(position);

      // Fetch a static map image with a marker
      final mapUrl =
          "https://maps.googleapis.com/maps/api/staticmap?center=${position.latitude},${position.longitude}&zoom=15&size=300x150&markers=color:red%7Clabel:C%7C${position.latitude},${position.longitude}&key=AIzaSyD9XZBYlnwfrKQ1ZK-EUxJtFePKXW_1sfE";
      final mapResponse = await http.get(Uri.parse(mapUrl));
      if (mapResponse.statusCode != 200) {
        debugPrint("Failed to load map image.");
        return;
      }
      final mapBytes = mapResponse.bodyBytes;

      // Decode both images (photo and map)
      img.Image? capturedImage = img.decodeImage(imageBytes);
      img.Image? mapImage = img.decodeImage(mapBytes);

      if (capturedImage == null || mapImage == null) {
        debugPrint("Unable to decode images.");
        return;
      }

      // Resize the map image to make it smaller
      final resizedMap = img.copyResize(mapImage, width: 400, height: 200);

      // Prepare text for geotag info
      final now = DateTime.now();
      final dateTimeStr =
          "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}:${now.second}";
      final geotagText = "Address:\n$address\n\n"
          "Coordinates:\n${position.latitude}, ${position.longitude}\n\n"
          "Date & Time:\n$dateTimeStr";

      // Determine text box dimensions
      final textBoxWidth = 400;
      final textBoxHeight = 120;

      // Create a new canvas to hold the original photo and additional info
      final extendedImage = img.copyResize(
        capturedImage,
        height: capturedImage.height + resizedMap.height + textBoxHeight,
      );

      // Add the map image at the bottom left
      img.copyInto(extendedImage, resizedMap,
          dstX: 0, dstY: capturedImage.height + 10);

      // Add geotag text next to the map
      img.fillRect(
        extendedImage,
        220, // x-coordinate for text box background
        capturedImage.height + 10, // y-coordinate for text box
        220 + textBoxWidth,
        capturedImage.height + 10 + textBoxHeight,
        img.getColor(0, 0, 0, 150), // Semi-transparent black background
      );
      img.drawString(
        extendedImage,
        img.arial_14,
        230, // x-coordinate for text
        capturedImage.height + 20, // y-coordinate for text
        geotagText,
        color: img.getColor(255, 255, 255), // White text
      );

      // Encode the final image
      final finalBytes = Uint8List.fromList(img.encodeJpg(extendedImage));

      // Save the final annotated image to the gallery
      final result = await ImageGallerySaverPlus.saveImage(
        finalBytes,
        name: "GeotaggedPhoto_${DateTime.now().millisecondsSinceEpoch}",
        quality: 100,
      );

      debugPrint("Save result: $result");

      if (!mounted) return;

      // Show a confirmation dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Photo Saved"),
          content: Text(
            "Photo saved with geotag info and map.\n\n"
            "Coordinates: (${position.latitude}, ${position.longitude})\n"
            "Address: $address\n"
            "Saved At: $dateTimeStr",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint("Error capturing and saving photo: $e");
    }
  }

  Future<void> _sendImageWithGeotag(
      File image, double latitude, double longitude, String description) async {
    try {
      final uri = Uri.parse(
          "http://3.109.174.127:3005/addappointmentapp"); // Replace with your API endpoint
      final request = http.MultipartRequest('POST', uri);

      // Add image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));

      request.fields['description'] = description.toString();
      // Add geotag to the request
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      // Send the request
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to upload image. Status: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
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

      //new fields
      request.fields['video'] =
          _vedio != null ? _vedio!.path : 'no vedio selected';
      request.fields['urine_test'] = urineCheck.toString();
      request.fields['ecg_test'] = ecgCheck.toString();
      request.fields['blood_test'] = bloodCheck.toString();
      request.fields['test_completed'] = _testStatus.toString();
      request.fields['reason'] = '';

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
      // Future.delayed(const Duration(seconds: 1), () {
      //   Navigator.of(context).pop(
      //       // MaterialPageRoute(
      //       //     builder: (context) => const AppointmentScreen(
      //       //           i: 1,
      //       //         )),
      //       );
      // });
    }
  }

  // Future<void> _pickImage() async {
  //   final pickedFile =
  //       await ImagePicker().pickImage(source: ImageSource.camera);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });

  //   }
  // }

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
            _videoController!.play();
          });
        });
    } else {
      setState(() {
        _isVedioLoding = false;
      });
    }
  }

  Future<void> _pickImagec() async {
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

        // Calculate the dimensions for the map and text area
        final mapWidth = capturedImage.width ~/ 2; // Half of the image width
        final mapHeight = (mapWidth * 150) / 300; // Aspect ratio 300x150
        final textBoxWidth =
            capturedImage.width ~/ 2; // Other half for the text
        final textBoxHeight = mapHeight.toInt(); // Match map height

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
            mapWidth, // Start at the right of the map
            capturedImage.height, // Align with the map's top edge
            capturedImage.width, // End at the canvas width
            capturedImage.height + mapHeight.toInt(), // Match map height
            img.getColor(0, 0, 0, 255), // Opaque black
          );

// Add the geotag text in the black box
          img.drawString(
            extendedImage,
            img.arial_48, // Larger font size
            mapWidth + 10, // Padding inside the black box
            capturedImage.height + 10, // Padding from the top edge
            geotagTextWithDate,
            color: img.getColor(255, 255, 255), // White text
          );
          // Save the updated image
          final updatedImageBytes = img.encodeJpg(extendedImage);
          final updatedImageFile = File(pickedFile.path)
            ..writeAsBytesSync(updatedImageBytes);

          setState(() {
            _image = updatedImageFile; // Save the updated image
            _imageloading = false;
          });
        } else {
          debugPrint("Failed to load map image: ${response.statusCode}");
        }
      } else {
        setState(() {
          _imageloading = false;
        });
      }
    } catch (e) {
      debugPrint("Error capturing and saving photo: $e");
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

// List<File> _images = []; // List to store multiple images
// bool _imageLoading = false; // Loading state

  Future<void> _pickMultipleImagess() async {
    try {
      List<File> tempImages = [];
      bool capturing = true; // Control variable for loop

      while (capturing) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile == null) {
          capturing = false; // Exit loop if user cancels
          break;
        }

        setState(() {
          _imageLoading = true;
        });

        File imageFile = File(pickedFile.path);
        final imageBytes = await imageFile.readAsBytes();

        // Decode the captured image
        img.Image capturedImage = img.decodeImage(imageBytes)!;

        // Get current location
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
        final mapHeight = (mapWidth * 150) / 300;

        // Construct Google Maps static URL
        final mapUrl =
            "https://maps.googleapis.com/maps/api/staticmap?center=${position.latitude},${position.longitude}&zoom=15&size=${mapWidth}x${mapHeight.toInt()}&markers=color:red%7Clabel:C%7C${position.latitude},${position.longitude}&key=YOUR_GOOGLE_MAPS_API_KEY";

        // Fetch map image
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

          tempImages.add(updatedImageFile);
        } else {
          debugPrint("Failed to load map image: ${response.statusCode}");
        }

        setState(() {
          _imageLoading = false;
        });

        // Ask the user if they want to take another picture
        capturing = await _askUserToContinue();
      }

      if (tempImages.isNotEmpty) {
        setState(() {
          _images.addAll(tempImages);
        });
      }
    } catch (e) {
      debugPrint("Error capturing and saving multiple photos: $e");
    }
  }

  Future<bool> _askUserToContinue() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Capture More?"),
            content: Text("Do you want to take another picture?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _pickMultipleImages() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        setState(() {
          _imageLoading = true;
        });

        List<File> tempImages = [];
        for (var pickedFile in pickedFiles) {
          tempImages.add(File(pickedFile.path));
        }

        setState(() {
          _images = tempImages;
          _imageLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error selecting images: $e");
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
    _nameController = TextEditingController(text: "Name: ${widget.clientName}");
    _medicalreportsController =
        TextEditingController(text: "Lab Reports: ${widget.medicalreports}");
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: const Color.fromRGBO(198, 201, 254, 1),
        title: const Text("Appointment Detail"),
        actions: <Widget>[
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.more_vert_outlined))
        ],
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
              TextField(
                readOnly: true,
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: "Time",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Enter Description",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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
                  ? const Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: "Remark",
                            hintText: "Enter Remark",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          height: 16,
                        )
                      ],
                    )
                  : const SizedBox(
                      height: 1,
                    ),

              Column(
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
                                    SizedBox(
                                      width: double
                                          .infinity, // Match container width
                                      height: 500, // Match container height
                                      child: FittedBox(
                                        fit: BoxFit
                                            .cover, // Ensures video fits nicely
                                        child: SizedBox(
                                          width: _videoController!
                                              .value.size.width,
                                          height: _videoController!
                                              .value.size.height,
                                          child: VideoPlayer(_videoController!),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 50,
                                      left: MediaQuery.of(context).size.width /
                                              2 -
                                          30,
                                      child: TextButton(
                                        onPressed: () {
                                          _videoController!.play();
                                        },
                                        child: const Text("Play"),
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
                      gradient: const LinearGradient(colors: [
                        Color.fromRGBO(143, 148, 251, 1),
                        Color.fromRGBO(143, 148, 251, .6),
                      ]),
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
