import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'widgets/curved_navbar.dart';

void main() {
  runApp(const TazamaApp());
}

class TazamaApp extends StatefulWidget {
  const TazamaApp({super.key});

  @override
  State<TazamaApp> createState() => _TazamaAppState();
}

class _TazamaAppState extends State<TazamaApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.blue,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
      home: HomePage(isDarkMode: _isDarkMode, toggleTheme: toggleTheme),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _mediaFile;
  bool _isUploading = false;
  bool _showUploadUI = false;

  static const String _apiUrl = 'https://your-ai-api-endpoint.com/process';

  // 🔹 Capture image or video
  Future<void> _captureMedia({required bool isVideo}) async {
    final pickedFile = isVideo
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() => _mediaFile = File(pickedFile.path));

    // Immediately upload
    await _uploadFile(_mediaFile!);
  }

  // 🔹 Upload file to AI endpoint
  Future<void> _uploadFile(File file) async {
    setState(() => _isUploading = true);

    final success = await _uploadToAI(file);
    await _deleteTempFile(file);

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      _mediaFile = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Upload successful!' : 'Upload failed!'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  // 🔹 Upload service
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

  // 🔹 Delete temporary file
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

  void _onUploadPressed() {
    setState(() {
      _showUploadUI = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            setState(() {
              _showUploadUI = false;
            });
          },
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white24,
              child: Icon(Icons.remove_red_eye, color: Colors.white, size: 16),
            ),
            SizedBox(width: 8),
            Text(
              "Tazama",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),

      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              alignment: _showUploadUI ? Alignment.topCenter : Alignment.center,
              child: Column(
                mainAxisAlignment: _showUploadUI
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.blueGrey[900]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Welcome to Tazama",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Seeing Through Sound",
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 Upload Image (now triggers camera)
                  ElevatedButton.icon(
                    onPressed: () => _captureMedia(isVideo: false),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "Upload Image",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Upload Video (now triggers camera)
                  ElevatedButton.icon(
                    onPressed: () => _captureMedia(isVideo: true),
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    label: const Text(
                      "Upload Video",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                  ),

                  if (_mediaFile != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _mediaFile!.path.endsWith('.mp4')
                          ? const Icon(Icons.videocam, size: 100)
                          : Image.file(_mediaFile!, height: 200),
                    ),
                ],
              ),
            ),

      bottomNavigationBar: TazamaNavBar(
        index: 0,
        onTap: (_) {},
        isDarkMode: widget.isDarkMode,
        showOnlyHome: true,
      ),
    );
  }
}
