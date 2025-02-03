import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'home_screen.dart';
import 'common_words.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _commonWordCounts = {};
    _fetchPreviousSessionsData();
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

  @override
  Widget build(BuildContext context) {
    double improvement = _lastSessionsAverage != null
        ? widget.withinLimitPercentage - _lastSessionsAverage!
        : 0.0;

    Color contourColor = _getContourColor(widget.withinLimitPercentage);

    List<Map<String, dynamic>> displayedSessions =
        _showLastFive ? _sessions.take(5).toList() : _sessions;

    double chartWidth =
        displayedSessions.length * 60.0; // Adjust width as needed
    double maxChartWidth = _sessions.length * 60.0; // Width for all sessions

    return Scaffold(
      appBar: AppBar(title: Text('Results')),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Within Limit Percentage',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
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
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Avg', style: TextStyle(fontSize: 12)),
                                    Text('WPM', style: TextStyle(fontSize: 12)),
                                    Text(widget.averageWpm.toStringAsFixed(1),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
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
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Message Card
                    Card(
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          improvement > 0
                              ? 'Great job! Your within limit percentage has improved by ${improvement.toStringAsFixed(2)}%'
                              : improvement < 0
                                  ? 'Keep trying! Your within limit percentage is lower by ${improvement.abs().toStringAsFixed(2)}%'
                                  : 'You have maintained the same within limit percentage as previous sessions.',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

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
                          Text("The chart is scrollable",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
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
                          child: Text("Last 5 Sessions"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showLastFive = false;
                            });
                          },
                          child: Text("All Sessions"),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Filler Words Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Filler Words',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ..._commonWordCounts.entries
                                .where((entry) => entry.value > 2)
                                .map((entry) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key,
                                      style: TextStyle(fontSize: 16)),
                                  Text('${entry.value}',
                                      style: TextStyle(fontSize: 16)),
                                ],
                              );
                            }).toList(),
                            if (!_commonWordCounts.values
                                .any((count) => count > 2))
                              Text(
                                  'Great job! No common words appeared more than twice.'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Access Speech Text Button
                    ElevatedButton(
                      onPressed: () => _showSpokenTextPopup(),
                      child: Text("Access Speech Text"),
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

  void _showSpokenTextPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Spoken Text"),
          content: SingleChildScrollView(
            child: Text(widget.spokenText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
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
      ..color = Colors.grey[300]!
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
