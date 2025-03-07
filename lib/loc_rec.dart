import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  _RecommendationsPageState createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  String location = "Fetching location...";
  List<String> recommendedVegetables = [];
  bool isLoading = false;

  final Map<String, List<String>> vegetableZones = {
    "Tropical": ["🍅 Tomato", "🌶 Chili", "🍆 Eggplant", "🌿 Okra", "🎃 Pumpkin"],
    "Temperate": ["🥕 Carrot", "🥬 Lettuce", "🌱 Spinach", "🥦 Broccoli", "🥬 Cabbage"],
    "Arid": ["🌵 Cactus Pear", "🧄 Garlic", "🧅 Onion", "🫑 Bell Pepper", "🥒 Zucchini"],
    "Cold": ["🥔 Potato", "🌰 Radish", "🍠 Beetroot", "🌿 Peas", "🥬 Kale"],
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
      _showError("❌ Location services are disabled. Enable GPS.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _showError("❌ Location permission denied.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      location = "📍 Lat: ${position.latitude}, Long: ${position.longitude}";
    });

    _recommendVegetables(position.latitude);
  }

  void _recommendVegetables(double latitude) {
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

  void _showError(String message) {
    setState(() {
      location = message;
      recommendedVegetables = [];
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grow With Location"),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                location,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : recommendedVegetables.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "🌱 Recommended Vegetables:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: recommendedVegetables
                                  .map(
                                    (veg) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.eco, color: Colors.green),
                                          const SizedBox(width: 10),
                                          Text(
                                            veg,
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          "No recommendations available.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}