import 'package:flutter/material.dart';
import 'loc_rec.dart'; // Import Recommendations page
import 'ai_reccomendation.dart'; // Import AI Recommendation page
import 'crop_detail.dart'; // Import Crop Details page

class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HexaFarm"),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.lightGreen[100],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Welcome, $username!",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCubeButton(
                  context,
                  icon: Icons.eco,
                  label: "Grow with Location",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecommendationsPage()),
                    );
                  },
                ),
                const SizedBox(width: 20),
                _buildCubeButton(
                  context,
                  icon: Icons.science,
                  label: "AI Recommendation",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  AIRecommendationPage()),
                    );
                  },
                ),
                const SizedBox(width: 20),
                _buildCubeButton(
                  context,
                  icon: Icons.local_florist,
                  label: "Crop Details",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CropDetailsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCubeButton(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}