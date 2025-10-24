import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  bool _isUploading = false;

  // 🔹 Step 1: Capture image or video
  Future<void> _captureMedia({required bool isVideo}) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() => _mediaFile = File(pickedFile.path));

    // Immediately upload
    await _uploadFile(_mediaFile!);
  }

  // 🔹 Step 2: Upload file to AI endpoint
  Future<void> _uploadFile(File file) async {
    setState(() => _isUploading = true);

    final success = await _uploadToAI(file);

    // Delete the file after upload
    await _deleteTempFile(file);

    setState(() {
      _isUploading = false;
      _mediaFile = null;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Upload successful!' : 'Upload failed!'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // 🔹 Step 3: Upload service (formerly UploadService)
  static const String _apiUrl = 'https://your-ai-api-endpoint.com/process';

  Future<bool> _uploadToAI(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Upload error: $e');
      return false;
    }
  }

  // 🔹 Step 4: Delete temporary file (formerly FileUtils)
  Future<void> _deleteTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint('Temporary file deleted');
      }
    } catch (e) {
      debugPrint('File deletion failed: $e');
    }
  }

  // 🔹 Step 5: UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture & Upload'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: _isUploading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_mediaFile != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _mediaFile!.path.endsWith('.mp4')
                          ? const Icon(Icons.videocam, size: 100)
                          : Image.file(_mediaFile!, height: 200),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture Image'),
                    onPressed: () => _captureMedia(isVideo: false),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('Record Video'),
                    onPressed: () => _captureMedia(isVideo: true),
                  ),
                ],
              ),
      ),
    );
  }
}
