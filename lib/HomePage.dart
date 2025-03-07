import 'package:flutter/material.dart';
import 'loc_rec.dart'; // Import Recommendations page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HexaFarm"),
        backgroundColor: Colors.green, // Green AppBar
      ),
      backgroundColor: Colors.lightGreen[100], // Light Green Background
      body: Center(
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
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Cube-like shape
            ),
            elevation: 5, // Add shadow for depth
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco,
                  color: Colors.white, size: 40), // Icon inside button
              SizedBox(height: 8),
              Text(
                "Grow with Location",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
