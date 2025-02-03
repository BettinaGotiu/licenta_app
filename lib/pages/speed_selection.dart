import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'speech_to_text.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);
final Color accentColor = Color(0xFFFF3926);
final Color cardColor = Color(0xFF973462);
final Color chartLineColor = Color(0xFF7670B9);
final Color backgroundColor = Color(0xFFEFF3FE);
final Color textColor = Colors.black87;

class SpeedSelectionPage extends StatefulWidget {
  final String nextPageRoute;
  final String? prompt;

  const SpeedSelectionPage({Key? key, required this.nextPageRoute, this.prompt})
      : super(key: key);

  @override
  _SpeedSelectionPageState createState() => _SpeedSelectionPageState();
}

class _SpeedSelectionPageState extends State<SpeedSelectionPage> {
  String? _selectedSpeed = '130-160'; // Default selection

  final Map<String, String> _speedDescriptions = {
    '100-130':
        'Slow pace (100-130 wpm) for speeches that require emphasis and reflection.',
    '130-160':
        'Normal pace (130-160 wpm) for clear and structured presentations.',
    '160-210':
        'Fast pace (160-210+ wpm) for dynamic situations requiring energy and enthusiasm.',
  };

  void _navigateToNextPage() {
    if (_selectedSpeed != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeechToTextPage(
            selectedPace: _selectedSpeed!,
            prompt: widget.prompt,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a speed before proceeding.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.7;
    final double cardHeight = 80;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Select Your Speaking Pace',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Nacelle',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48), // Placeholder for alignment
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Speed Selection Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _speedDescriptions.keys.map((speed) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpeed = speed;
                    });
                  },
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: _selectedSpeed == speed
                          ? secondaryColor
                          : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      speed,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _selectedSpeed == speed
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // Explanation Card
            Container(
              width: double.infinity, // Make the card wider
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(10, 10),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Why Choose This Speed?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _speedDescriptions[_selectedSpeed!]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Proceed Button
            ElevatedButton(
              onPressed: _selectedSpeed != null ? _navigateToNextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Start Speech Exercise',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
