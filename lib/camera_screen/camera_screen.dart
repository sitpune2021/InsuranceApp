import 'package:geolocator/geolocator.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:map_camera_flutter/map_camera_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img; // Used for image processing

import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo with Geotag, Address, and Date/Time'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Display camera preview if initialized
            return CameraPreview(_controller);
          } else {
            // Otherwise, a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureAndSave,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
