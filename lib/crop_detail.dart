import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CropDetailsPage extends StatefulWidget {
  const CropDetailsPage({super.key});

  @override
  _CropDetailsPageState createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  String? selectedCrop;
  String cropDetails = "Select a vegetable to see details.";
  bool isLoading = false;

  // List of vegetables for the dropdown
  final List<String> vegetables = [
    "Tomato",
    "Potato",
    "Carrot",
    "Lettuce",
    "Radish",
    "Spinach",
    "Green Onion",
    "Basil",
    "Cucumber",
    "Bell Pepper",
  ];

  // Load crop data from the local JSON file
  Future<List<dynamic>> loadCropData() async {
    final String response = await rootBundle.loadString('assets/crops.json');
    return json.decode(response);
  }

  Future<void> fetchCropDetails(String cropName) async {
    setState(() {
      isLoading = true;
      cropDetails = "Fetching details for $cropName...";
    });

    try {
      final cropData = await loadCropData();

      // Find the crop in the JSON data
      final crop = cropData.firstWhere(
        (crop) => crop['name'].toLowerCase() == cropName.toLowerCase(),
        orElse: () => null,
      );

      if (crop != null) {
        setState(() {
          cropDetails = """
🌱 Soil: ${crop['soil'] ?? 'N/A'}
💧 Watering: ${crop['watering'] ?? 'N/A'}
☀️ Sunlight: ${crop['sunlight'] ?? 'N/A'}
📅 Planting Season: ${crop['planting_season'] ?? 'N/A'}
📏 Spacing: ${crop['spacing'] ?? 'N/A'}
🌱 Germination Time: ${crop['germination_time'] ?? 'N/A'}
⏳ Harvest Time: ${crop['harvest_time'] ?? 'N/A'}
🌿 Fertilizer: ${crop['fertilizer'] ?? 'N/A'}
🐛 Pests: ${crop['pests'] ?? 'N/A'}
💡 Tips: ${crop['tips'] ?? 'N/A'}
        """;
        });
      } else {
        setState(() {
          cropDetails = "No details found for $cropName.";
        });
      }
    } catch (e) {
      setState(() {
        cropDetails = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Vegetable:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedCrop,
              hint: const Text("Choose a vegetable"),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCrop = newValue;
                });
                if (newValue != null) {
                  fetchCropDetails(newValue);
                }
              },
              items: vegetables.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              "Growing Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green))
                : Text(
                    cropDetails,
                    style: const TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
