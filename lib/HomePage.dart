import 'package:flutter/material.dart';
import 'loc_rec.dart'; // Import Recommendations page

class HomePage extends StatelessWidget {
  final String username; // Accept username

  const HomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HexaFarm"),
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false, // Removes back button
      ),
      backgroundColor: Colors.lightGreen[100], // Light Green Background
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Welcome, $username!", // Welcome message
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30), // Spacing
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Recommendations Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecommendationsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Cube-like shape
                ),
                elevation: 5, // Adds shadow for depth
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.eco, color: Colors.white, size: 40), // Icon inside button
                  SizedBox(height: 8),
                  Text(
                    "Grow with Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
