import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AppointmentViewerScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentViewerScreen({
    Key? key,
    required this.appointmentId,
  }) : super(key: key);

  @override
  State<AppointmentViewerScreen> createState() =>
      _AppointmentViewerScreenState();
}

class _AppointmentViewerScreenState extends State<AppointmentViewerScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? appointmentData;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  List<File> _images = [];
  File? _video;
  String _baseUrl = "http://103.165.118.71:8085";

  @override
  void initState() {
    super.initState();
    _fetchAppointmentData();
  }

  Future<void> _fetchAppointmentData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/getCompletedAppointmentByTechnician/${widget.appointmentId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming the API returns a list of appointments even if it's just one
        if (data is List && data.isNotEmpty) {
          appointmentData = data[0];
        } else if (data is Map) {
          appointmentData = data.cast<String, dynamic>();
        }

        if (appointmentData != null) {
          await _loadMediaFiles();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to load appointment: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load media files (images and video)
  Future<void> _loadMediaFiles() async {
    // Clear existing media
    _images.clear();
    _video = null;

    // Load images
    if (appointmentData!.containsKey('images') &&
        appointmentData!['images'] != null &&
        appointmentData!['images'].toString().isNotEmpty) {
      try {
        final List<dynamic> imagesList = appointmentData!['images'] is String
            ? json.decode(appointmentData!['images'])
            : appointmentData!['images'];

        for (String imagePath in imagesList) {
          try {
            final File imageFile = await _downloadFile('$_baseUrl/$imagePath');
            print("Downloaded image file: ${imageFile.path}");
            if (await imageFile.exists()) {
              _images.add(imageFile);
            } else {
              print("Downloaded file doesn't exist: ${imageFile.path}");
            }
          } catch (e) {
            print('Error downloading image $imagePath: $e');
          }
        }
      } catch (e) {
        print('Error parsing images: $e');
      }
    }

    // Load video
    if (appointmentData!.containsKey('video') &&
        appointmentData!['video'] != null &&
        appointmentData!['video'].toString().isNotEmpty) {
      try {
        final String videoPath = appointmentData!['video'];
        _video = await _downloadFile('$_baseUrl/$videoPath');
        print("Downloaded video file: ${_video?.path}");
        if (await _video!.exists()) {
          _initializeVideo();
        } else {
          print("Downloaded video file doesn't exist");
        }
      } catch (e) {
        print('Error loading video: $e');
      }
    }
  }

  // Download file from server
  Future<File> _downloadFile(String url) async {
    print("Downloading file from: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = url.split('/').last;
    final File file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    print(
        "File downloaded to: ${file.path}, Size: ${response.bodyBytes.length} bytes");
    return file;
  }

  void _initializeVideo() async {
    if (_video != null) {
      try {
        print("Initializing video controller for: ${_video!.path}");
        _videoController = VideoPlayerController.file(_video!);
        await _videoController!.initialize();
        setState(() {
          _isVideoInitialized = true;
        });
      } catch (e) {
        print('Error initializing video: $e');
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
        title: const Text("Appointment Details"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointmentData == null
              ? const Center(child: Text("No appointment data found"))
              : _buildAppointmentDetails(),
    );
  }

  Widget _buildAppointmentDetails() {
    final TestStatus testStatus =
        appointmentData!['test_completed'] == "TestStatus.completed"
            ? TestStatus.completed
            : TestStatus.notCompleted;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildInfoCard("Name", appointmentData!['name'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoCard("Treatment", appointmentData!['treatment'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoCard("Date", appointmentData!['time'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoCard(
                "Description", appointmentData!['description'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildInfoCard(
                "Mobile Number", appointmentData!['mobileno'] ?? 'N/A'),
            // const SizedBox(height: 16),
            // _buildInfoCard("Appointment Number",
            //     appointmentData!['appointment_no'] ?? 'N/A'),
            const SizedBox(height: 24),

            // Tests section
            const Text(
              "Diagnostic Tests",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Test checkboxes (read-only)
            _buildTestItem(
                "Urine Test", appointmentData!['urine_test'] == "true"),
            const SizedBox(height: 8),
            _buildTestItem(
                "Blood Test", appointmentData!['blood_test'] == "true"),
            const SizedBox(height: 8),
            _buildTestItem("ECG", appointmentData!['ecg_test'] == "true"),
            const SizedBox(height: 16),

            // Test status
            _buildInfoCard(
                "Test Status",
                testStatus == TestStatus.completed
                    ? "Completed"
                    : "Not Completed"),

            // Reason (if test is not completed)
            if (testStatus == TestStatus.notCompleted &&
                appointmentData!['reason'] != null)
              Column(
                children: [
                  const SizedBox(height: 16),
                  _buildInfoCard("Reason", appointmentData!['reason']),
                ],
              ),

            // Location
            // if (appointmentData!['latitude'] != null &&
            //     appointmentData!['longitude'] != null)
            //   Column(
            //     children: [
            //       const SizedBox(height: 16),
            //       _buildInfoCard("Location",
            //           "Lat: ${appointmentData!['latitude']}, Long: ${appointmentData!['longitude']}"),
            //     ],
            //   ),

            // Images section
            if (_images.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Uploaded Images",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildImagesGrid(),
                ],
              ),

            // Video section
            if (_video != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Uploaded Video",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVideoPlayer(),
                ],
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget to display information in a card format
  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display test items with checkbox (read-only)
  Widget _buildTestItem(String label, bool value) {
    return Card(
      margin: const EdgeInsets.all(0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: Colors.black54, width: 1),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
            ),
            Checkbox(
              value: value,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: null, // Read-only
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display images in a grid
  Widget _buildImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showFullImage(context, _images[index]),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.file(
                _images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("Error loading image: $error");
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget to display video player
  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: () {
        if (_isVideoInitialized && _videoController != null) {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        } else if (_video != null && !_isVideoInitialized) {
          // Try to initialize the video again if it failed previously
          _initializeVideo();
        }
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _video == null
            ? const Center(
                child: Text(
                  "No video available",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : !_isVideoInitialized
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 10),
                        const Text(
                          "Loading video...",
                          style: TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: _initializeVideo,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  )
                : _videoController!.value.hasError
                    ? _buildVideoErrorWidget()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: 90 *
                                3.1415926535 /
                                180, // 90 degrees in radians
                            child: AspectRatio(
                              aspectRatio: _videoController!.value.aspectRatio,
                              child: SizedBox(
                                width: double.infinity,
                                height: 500,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: _videoController!.value.size.width,
                                    height: _videoController!.value.size.height,
                                    child: VideoPlayer(_videoController!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _videoController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              size: 48,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            onPressed: () {
                              setState(() {
                                _videoController!.value.isPlaying
                                    ? _videoController!.pause()
                                    : _videoController!.play();
                              });
                            },
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildVideoErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            "Failed to load video",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          ElevatedButton(
            onPressed: _initializeVideo,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // Method to show image in full screen
  void _showFullImage(BuildContext context, File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.file(
                  image,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error in full screen image: $error");
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image,
                                size: 100, color: Colors.white),
                            SizedBox(height: 20),
                            Text(
                              "Failed to load image",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum TestStatus { completed, notCompleted }
