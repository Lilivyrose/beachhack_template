import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RecommendationsPage extends StatefulWidget {
  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  String location = "Fetching location...";
  List<String> recommendedVegetables = [];
  bool isLoading = false;

  final Map<String, List<String>> vegetableZones = {
    "Tropical": ["Tomato", "Chili", "Eggplant", "Okra", "Pumpkin"],
    "Temperate": ["Carrot", "Lettuce", "Spinach", "Cabbage", "Broccoli"],
    "Arid": ["Cactus Pear", "Onion", "Garlic", "Bell Pepper", "Zucchini"],
    "Cold": ["Potato", "Radish", "Beetroot", "Peas", "Kalflutter e"],
  };

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    setState(() => isLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = "Location services are disabled.";
        isLoading = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          location = "Location permissions are denied.";
          isLoading = false;
        });
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      location = "Lat: ${position.latitude}, Long: ${position.longitude}";
    });

    recommendVegetables(position.latitude);
  }

  void recommendVegetables(double latitude) {
    String zone;

    if (latitude >= 23.5) {
      zone = "Temperate";
    } else if (latitude <= -23.5) {
      zone = "Cold";
    } else if (latitude.abs() < 10) {
      zone = "Tropical";
    } else {
      zone = "Arid";
    }

    setState(() {
      recommendedVegetables = vegetableZones[zone] ?? ["No data available"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grow with Location",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green, // Matches other pages
        elevation: 4, // Slight shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: $location", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recommended Vegetables:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...recommendedVegetables.map(
                        (veg) => Text("- $veg", style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
