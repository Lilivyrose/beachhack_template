import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';

class AIRecommendationPage extends StatefulWidget {
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
        SnackBar(content: Text("Please select an image first!"))
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
      appBar: AppBar(title: Text("AI Recommendation")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("Upload a Balcony/Outdoor Image", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _selectedImage != null
                ? Image.memory(_selectedImage!, width: 300, height: 200, fit: BoxFit.cover)
                : Text("No image selected"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Upload Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadAndAnalyzeImage,
              child: Text("Analyze"),
            ),
            SizedBox(height: 20),
            _outputImage != null
                ? Column(
                    children: [
                      Text("Optimized Layout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Image.memory(_outputImage!, width: 300, height: 200, fit: BoxFit.cover),
                      SizedBox(height: 20),
                      _buildColorCodeLegend(), // Add color code legend
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCodeLegend() {
    return Column(
      children: [
        Text("Color Code Guide", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildColorLegendItem(Colors.green, "Green - Plants in Pots"),
        _buildColorLegendItem(Colors.blue, "Blue - Hanging Plants"),
        _buildColorLegendItem(Colors.red, "Red - Trellis Plants (Climbers)"),
      ],
    );
  }

  Widget _buildColorLegendItem(Color color, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 20, height: 20, color: color),
        SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
