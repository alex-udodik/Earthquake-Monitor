import 'package:flutter/material.dart';

class CountryDetailScreen extends StatelessWidget {
  final String countryName;

  const CountryDetailScreen({Key? key, required this.countryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with back button
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    countryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.grey),

            // Example content — you can customize this
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This is a detailed screen for $countryName. You could add stats, charts, or emissions info here.',
                      style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.702),
                          fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Placeholder(
                      fallbackHeight: 200,
                      color: Colors.tealAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
