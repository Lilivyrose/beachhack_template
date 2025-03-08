import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';

class AIRecommendationPage extends StatefulWidget {
  const AIRecommendationPage({super.key});

  @override
  _AIRecommendationPageState createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  Uint8List? _selectedImage;
  Uint8List? _outputImage;
  String? _filename;

  void _pickImage() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = "image/*"; // Allow only images
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();

        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedImage = reader.result as Uint8List?;
            _filename = file.name;
          });
        });
      }
    });
  }

  Future<void> _uploadAndAnalyzeImage() async {
    if (_selectedImage == null || _filename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first!"))
      );
      return;
    }

    var uri = Uri.parse("http://127.0.0.1:5000/upload");
    var request = http.MultipartRequest("POST", uri);
    request.files.add(http.MultipartFile.fromBytes(
      "file", 
      _selectedImage!,
      filename: _filename!,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var filename = jsonDecode(responseBody)["filename"];

      // Now send a request to analyze the image
      var analyzeResponse = await http.post(
        Uri.parse("http://127.0.0.1:5000/analyze"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"filename": filename}),
      );

      if (analyzeResponse.statusCode == 200) {
        var outputFilename = jsonDecode(analyzeResponse.body)["output_filename"];
        var imageResponse = await http.get(Uri.parse("http://127.0.0.1:5000/get_output/$outputFilename"));

        setState(() {
          _outputImage = imageResponse.bodyBytes;
        });
      } else {
        print("Analysis failed: ${analyzeResponse.body}");
      }
    } else {
      print("Upload failed: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Space Analysis")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Upload a Balcony/Outdoor Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              
              _selectedImage != null
                  ? Image.memory(
                      _selectedImage!,
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 300,
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text("No image selected"),
                    ),
              
              const SizedBox(height: 20),
              
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Upload Image"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _uploadAndAnalyzeImage,
                child: const Text("Analyze"),
              ),

              const SizedBox(height: 20),

              _outputImage != null
                  ? Column(
                      children: [
                        const Text(
                          "Optimized Layout",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Image.memory(
                          _outputImage!,
                          width: 300,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
