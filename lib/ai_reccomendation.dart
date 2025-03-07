import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';



class AIRecommendationPage extends StatefulWidget {
  @override
  _AIRecommendationPageState createState() => _AIRecommendationPageState();
}

class _AIRecommendationPageState extends State<AIRecommendationPage> {
  File? _image;
  int? _brightness;
  String? _location;
  List<String> _vegetables = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _analyzeImage();
      await _fetchLocation();
      await _fetchVegetables();
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    final bytes = await _image!.readAsBytes();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) return;

    int totalBrightness = 0;
    for (int y = 0; y < decodedImage.height; y++) {
      for (int x = 0; x < decodedImage.width; x++) {
        final pixel = decodedImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        totalBrightness += ((r + g + b) ~/ 3);
      }
    }

    setState(() {
      _brightness = totalBrightness ~/ (decodedImage.width * decodedImage.height);
    });
  }

  Future<void> _fetchLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = "Location services disabled";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = "Location permission denied";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = "Location permissions permanently denied";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "${position.latitude},${position.longitude}";
    });
  }

  Future<void> _fetchVegetables() async {
    if (_location == null) return;

    // Fetch weather data (brightness proxy)
    final weatherUrl = "https://api.open-meteo.com/v1/forecast?latitude=${_location!.split(',')[0]}&longitude=${_location!.split(',')[1]}&current=weathercode";
    final weatherResponse = await http.get(Uri.parse(weatherUrl));

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);
      int weatherCode = weatherData["current"]["weathercode"];

      // Send brightness + weather data to a recommendation API (Replace with a real API)
      final recommendationUrl = "https://vegetable-recommendation-api.com/get?weather=$weatherCode&brightness=${_brightness ?? 50}";
      final recResponse = await http.get(Uri.parse(recommendationUrl));

      if (recResponse.statusCode == 200) {
        final data = json.decode(recResponse.body);
        setState(() {
          _vegetables = List<String>.from(data["vegetables"]);
        });
      } else {
        setState(() {
          _vegetables = ["Tomato", "Lettuce", "Carrot"]; // Default recommendation
        });
      }
    } else {
      setState(() {
        _vegetables = ["Tomato", "Lettuce", "Carrot"]; // Default fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Farming Assistant")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text("No image selected", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            TextButton(
              onPressed: _pickImage,
              child: Text("Pick an Image"),
            ),
            SizedBox(height: 20),
            Text("Brightness: ${_brightness ?? 'Not analyzed'}", style: TextStyle(fontSize: 16)),
            Text("Location: ${_location ?? 'Not fetched'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Recommended Vegetables:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ..._vegetables.map((veg) => Text(veg, style: TextStyle(fontSize: 16))).toList(),
          ],
        ),
      ),
    );
  }
}