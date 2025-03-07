import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


class AIRecommendationPage extends StatefulWidget {
  @override
  _AIRecommendationPageState createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  File? _image;
  String? _outputImageUrl;
  bool _isUploading = false;
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _outputImageUrl = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5000/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      String filename = jsonResponse['filename'];
      _analyzeImage(filename);
    } else {
      setState(() {
        _isUploading = false;
      });
      _showError(jsonResponse['error']);
    }
  }

  Future<void> _analyzeImage(String filename) async {
    setState(() {
      _isAnalyzing = true;
    });

    var response = await http.post(
      Uri.parse('http://127.0.0.1:5000/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'filename': filename}),
    );

    var jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _outputImageUrl = 'http://127.0.0.1:5000/get_output/${jsonResponse['output_filename']}';
        _isAnalyzing = false;
        _isUploading = false;
      });
    } else {
      setState(() {
        _isAnalyzing = false;
        _isUploading = false;
      });
      _showError(jsonResponse['error']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hexa Farm Analyzer")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text("No image selected", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
            ),
            SizedBox(height: 10),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _uploadImage,
                    child: Text("Analyze"),
                  ),
            SizedBox(height: 20),
            _outputImageUrl != null
                ? Column(
                    children: [
                      Image.network(_outputImageUrl!, height: 200),
                      SizedBox(height: 10),
                      Text("Analysis complete!"),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
