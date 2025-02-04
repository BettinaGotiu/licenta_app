import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'sessions_service.dart';
import 'history_screen.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);
final Color accentColor = Color(0xFFFF3926);
final Color cardColor = Color(0xFF973462);
final Color backgroundColor = Color(0xFFEFF3FE);
final Color textColor = Colors.black87;

class SessionScreen extends StatelessWidget {
  final Map<String, dynamic> session;
  final int sessionNumber;

  const SessionScreen({
    Key? key,
    required this.session,
    required this.sessionNumber,
  }) : super(key: key);

  Color _getContourColor(double percentage) {
    if (percentage > 70) return Colors.green;
    if (percentage > 40) return Colors.yellow;
    if (percentage > 0) return Colors.red;
    return Colors.grey;
  }

  List<TextSpan> _buildHighlightedText(
      String text, Map<String, int> commonWordCounts) {
    List<TextSpan> spans = [];
    text.split(' ').forEach((word) {
      if (commonWordCounts.containsKey(word.toLowerCase()) &&
          commonWordCounts[word.toLowerCase()]! >= 2) {
        spans.add(TextSpan(
            text: '$word ',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)));
      } else {
        spans.add(TextSpan(
            text: '$word ',
            style: TextStyle(fontSize: 16, color: Colors.black)));
      }
    });
    return spans;
  }

  void _showSpokenTextPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Spoken Text"),
          content: SingleChildScrollView(
            child: Text(session['spokenText']),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHelpPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filler Words"),
          content: Text(
              "Track filler words, which are commonly used words in speeches and daily conversations. These words should be avoided for more effective communication.\n\nCommon filler words include: actually, basically, like, literally, you know."),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showWithinLimitHelpPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Within Limit Percentage"),
          content: Text(
              "The Within Limit Percentage indicates how often you stayed within the desired speaking limits during your session. Higher percentages suggest that you were more consistent and controlled in your speech, adhering closely to your target speaking rates and other set limits."),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double withinLimitPercentage = session['withinLimitPercentage'];
    double averageWpm = session['averageWpm'];
    Map<String, int> commonWordCounts =
        Map<String, int>.from(session['commonWordCounts']);
    int maxOccurrence = commonWordCounts.values.isNotEmpty
        ? commonWordCounts.values.reduce((a, b) => a > b ? a : b)
        : 0;

    // Ensure all words are displayed, even if their occurrences are 0
    List<String> allWords = [
      'actually',
      'basically',
      'like',
      'literally',
      'you know'
    ];
    for (String word in allWords) {
      if (!commonWordCounts.containsKey(word)) {
        commonWordCounts[word] = 0;
      }
    }

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
              padding:
                  const EdgeInsets.only(top: 30.0, bottom: 20.0, left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Session $sessionNumber',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nacelle',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Within Limit Percentage Title and Help Icon
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Within Limit Percentage',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.grey),
                    onPressed: () => _showWithinLimitHelpPopup(context),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Within Limit Percentage Bubble
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(160, 160),
                        painter: ContourPainter(withinLimitPercentage),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 4),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            '${withinLimitPercentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Average WPM in Circle
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          averageWpm.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text('AVG WPM', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Filler Words Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Filler Words',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.help_outline, color: Colors.grey),
                          onPressed: () => _showHelpPopup(context),
                        ),
                      ],
                    ),
                    ...commonWordCounts.entries.map((entry) {
                      double lineWidth = maxOccurrence != 0
                          ? (entry.value / maxOccurrence) * 200
                          : 0;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: entry.value >= 2,
                                    onChanged: (bool? value) {},
                                  ),
                                  SizedBox(width: 5),
                                  Text(entry.key,
                                      style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              Text('${entry.value}',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          Container(
                            width: lineWidth,
                            height: 10,
                            decoration: BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Access Speech Text Button
              Center(
                child: ElevatedButton(
                  onPressed: () => _showSpokenTextPopup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "Access Speech Text",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContourPainter extends CustomPainter {
  final double percentage;

  ContourPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = _getContourColor(percentage)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8; // Adjusted to make it more visible

    final Paint backgroundPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8; // Adjusted to make it more visible

    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final double startAngle = -90.0;
    final double sweepAngle = 360.0 * (percentage / 100.0);

    canvas.drawArc(rect, startAngle * (3.14159 / 180.0),
        360.0 * (3.14159 / 180.0), false, backgroundPaint);
    canvas.drawArc(rect, startAngle * (3.14159 / 180.0),
        sweepAngle * (3.14159 / 180.0), false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Color _getContourColor(double percentage) {
    if (percentage > 70) return Colors.green;
    if (percentage > 40) return Colors.yellow;
    if (percentage > 0) return Colors.red;
    return Colors.grey;
  }
}
