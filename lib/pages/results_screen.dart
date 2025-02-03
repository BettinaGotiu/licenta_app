import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'home_screen.dart';
import 'common_words.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);
final Color accentColor = Color(0xFFFF3926);
final Color cardColor = Color(0xFF973462);
final Color chartLineColor = Color(0xFF7670B9);
final Color backgroundColor = Color(0xFFEFF3FE);
final Color textColor = Colors.black87;

class ResultsScreen extends StatefulWidget {
  final String spokenText;
  final double averageWpm;
  final double withinLimitPercentage;

  const ResultsScreen({
    Key? key,
    required this.spokenText,
    required this.averageWpm,
    required this.withinLimitPercentage,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Map<String, int> _commonWordCounts;
  bool _isLoading = true;
  double? _lastSessionsAverage;
  List<Map<String, dynamic>> _sessions = [];
  bool _showText = false;
  bool _showLastFive = true; // Track which data to display
  List<String> _allWords = [];

  @override
  void initState() {
    super.initState();
    _commonWordCounts = {};
    _fetchWordsAndCount();
    _fetchPreviousSessionsData();
  }

  Future<void> _fetchWordsAndCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user.uid)
          .get();

      List<String> personalizedWords = [];
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('commonWordCounts')) {
          personalizedWords = data['commonWordCounts'].keys.toList();
        }
      }

      setState(() {
        _allWords = [...commonWords, ...personalizedWords];
        _countCommonWords();
      });
    }
  }

  void _countCommonWords() {
    // Initialize counts to 0
    _allWords.forEach((expression) {
      _commonWordCounts[expression] = 0;
    });

    // Count occurrences of each expression
    for (String expression in _allWords) {
      _commonWordCounts[expression] =
          _countOccurrences(widget.spokenText, expression);
    }
  }

  int _countOccurrences(String text, String pattern) {
    RegExp regExp = RegExp(RegExp.escape(pattern), caseSensitive: false);
    return regExp.allMatches(text).length;
  }

  Future<void> _fetchPreviousSessionsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference userCollection = FirebaseFirestore.instance
          .collection('user_data')
          .doc(user.uid)
          .collection('sessions');

      final snapshot = await userCollection.orderBy('date').get();
      setState(() {
        _sessions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _lastSessionsAverage = _sessions.isNotEmpty
            ? _sessions
                    .map((s) => s['withinLimitPercentage'] as double)
                    .reduce((a, b) => a + b) /
                _sessions.length
            : 0.0;
        _isLoading = false;
      });
    }
  }

  Color _getContourColor(double percentage) {
    if (percentage > 70) return Colors.green;
    if (percentage > 40) return Colors.yellow;
    if (percentage > 0) return Colors.red;
    return Colors.grey;
  }

  List<TextSpan> _buildHighlightedText(String text) {
    List<TextSpan> spans = [];
    text.split(' ').forEach((word) {
      if (_commonWordCounts.containsKey(word.toLowerCase()) &&
          _commonWordCounts[word.toLowerCase()]! >= 2) {
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

  void _showSpokenTextPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Spoken Text"),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                children: _buildHighlightedText(widget.spokenText),
              ),
            ),
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

  void _showHelpPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filler Words"),
          content: Text(
              "Track filler words, which are commonly used words in speeches and daily conversations. These words should be avoided for more effective communication."),
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

  void _showWithinLimitPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Within Limit Percentage"),
          content: Text(
              "Percentage of user respecting the selected limits during the session."),
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

  void _showProgressBarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Progress Bar"),
          content: Text(
              "Access to your data so you can track your progress in time."),
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
    double improvement = _lastSessionsAverage != null
        ? widget.withinLimitPercentage - _lastSessionsAverage!
        : 0.0;

    Color contourColor = _getContourColor(widget.withinLimitPercentage);
    Color borderColor;

    if (improvement > 0) {
      borderColor = Colors.green;
    } else if (improvement < 0) {
      borderColor = Colors.red;
    } else {
      borderColor = Colors.yellow;
    }

    List<Map<String, dynamic>> displayedSessions =
        _showLastFive ? _sessions.take(5).toList() : _sessions;

    double chartWidth =
        displayedSessions.length * 60.0; // Adjust width as needed
    double maxChartWidth = _sessions.length * 60.0; // Width for all sessions

    int maxOccurrence = _commonWordCounts.values.isNotEmpty
        ? _commonWordCounts.values.reduce((a, b) => a > b ? a : b)
        : 0;

    int minOccurrence = _commonWordCounts.values.isNotEmpty
        ? _commonWordCounts.values.reduce((a, b) => a < b ? a : b)
        : 0;

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
                    'Results',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align to the left
                  children: [
                    // Stylish Text
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
                          onPressed: _showWithinLimitPopup,
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
                              painter:
                                  ContourPainter(widget.withinLimitPercentage),
                            ),
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 4),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.withinLimitPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Row with Average WPM and Improvement Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.averageWpm.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('AVG WPM', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      improvement >= 0
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: improvement >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      size: 24,
                                    ),
                                    Text(
                                      '${improvement.abs().toStringAsFixed(2)}%',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text('Progress', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Message Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: borderColor, width: 3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0, 3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        improvement > 0
                            ? 'Great job! Your within limit percentage has improved by ${improvement.toStringAsFixed(2)}%'
                            : improvement < 0
                                ? 'Keep trying! Your within limit percentage is lower by ${improvement.abs().toStringAsFixed(2)}%'
                                : 'You have maintained the same within limit percentage as previous sessions.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Progress Bar Title and Help Icon
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Progress Bar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.help_outline, color: Colors.grey),
                          onPressed: _showProgressBarPopup,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Line Chart
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: _showLastFive ? chartWidth : maxChartWidth,
                        child: _buildLineChart(displayedSessions),
                      ),
                    ),
                    if (!_showLastFive)
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Center(
                            child: Text("The chart is scrollable",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ),
                        ],
                      ),
                    SizedBox(height: 30),

                    // Toggle Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showLastFive = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "Last 5 Sessions",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showLastFive = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            "All Sessions",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.help_outline,
                                    color: Colors.grey),
                                onPressed: _showHelpPopup,
                              ),
                            ],
                          ),
                          ..._commonWordCounts.entries
                              .where((entry) => entry.value >= 2)
                              .map((entry) {
                            double lineWidth = maxOccurrence != 0
                                ? (entry.value / maxOccurrence) * 200
                                : 0;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: true, // Checked by default
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
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                ),
                              ],
                            );
                          }).toList(),
                          if (!_commonWordCounts.values
                              .any((count) => count >= 2))
                            Text(
                                'Great job! No common words appeared more than twice.'),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Access Speech Text Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _showSpokenTextPopup(),
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

  Widget _buildLineChart(List<Map<String, dynamic>> sessions) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: Chart(
        layers: [
          ChartAxisLayer(
            labelX: (value) => value.toInt().toString(),
            labelY: (value) => value.toString(),
            settings: ChartAxisSettings(
              x: ChartAxisSettingsAxis(
                frequency: 1.0,
                max: sessions.length.toDouble(),
                min: 1.0,
                textStyle: TextStyle(color: Colors.black),
              ),
              y: ChartAxisSettingsAxis(
                frequency: 10.0,
                max: 100.0,
                min: 0.0,
                textStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          ChartLineLayer(
            items: sessions
                .asMap()
                .entries
                .map((entry) => ChartLineDataItem(
                      x: entry.key + 1,
                      value: entry.value['withinLimitPercentage'].toDouble(),
                    ))
                .toList(),
            settings: ChartLineSettings(
              color: Colors.blue,
              thickness: 2.0,
            ),
          ),
        ],
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
