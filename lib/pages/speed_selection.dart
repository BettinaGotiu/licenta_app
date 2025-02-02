import 'package:flutter/material.dart';
import 'speech_to_text.dart';

class SpeedSelectionPage extends StatefulWidget {
  final String nextPageRoute;

  const SpeedSelectionPage({Key? key, required this.nextPageRoute})
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
          builder: (context) => SpeechToTextPage(selectedPace: _selectedSpeed!),
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
    return Scaffold(
      backgroundColor: Colors.white, // Clean background
      appBar: AppBar(
        title: const Text('Select Speaking Pace'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'Select Your Speaking Pace',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Speed Selection Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              children: _speedDescriptions.keys.map((speed) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpeed = speed;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          _selectedSpeed == speed ? Colors.blue : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(34),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      speed,
                      style: TextStyle(
                        fontSize: 18,
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
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
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Proceed to Speech-to-Text',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
