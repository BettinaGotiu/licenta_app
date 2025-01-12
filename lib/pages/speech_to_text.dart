import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SpeechToTextPage(),
    );
  }
}

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _currentText = "";
  bool _hasSpeechError = false;

  Stopwatch _stopwatch = Stopwatch();
  Stopwatch _elapsedStopwatch = Stopwatch();
  late Timer _timer;
  late Timer _wpmTimer;

  List<String> _recognizedParagraphs = [];
  List<int> _recordingDurations = [];
  List<int> _wordCounts = [];
  List<double> _wpmList = [];

  double _currentWpm = 0.0;
  List<double> _wpmHistory = [];
  int _withinLimitCount = 0;

  final ScrollController _scrollController = ScrollController();

  String? _selectedPace;
  String _warningMessage = '';
  bool _paceSelected = false;
  final int _intervalDuration = 6;
  int _listeningSessionCounter = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  int _countWords(String text) {
    return text.split(RegExp(r'\s+')).length;
  }

  double _calculateWPM(int wordCount, int duration) {
    if (duration == 0) return 0;
    return (wordCount / duration) * 60;
  }

  void _startListening() async {
    if (_selectedPace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a pace before starting."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _paceSelected = true;
      _listeningSessionCounter++;
      if (_listeningSessionCounter == 1) {
        _elapsedStopwatch.start();
      }
    });

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == "done" && _isListening) {
          _stopListening();
        }
      },
      onError: (error) {
        debugPrint("Error: ${error.errorMsg}, permanent: ${error.permanent}");
        if (error.errorMsg == "error_speech_timeout" && _isListening) {
          _stopListening();
        } else if (error.errorMsg == "error_no_match") {
          _restartListeningOnError();
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _currentText = "";
        _hasSpeechError = false;
        _stopwatch.reset();
        _stopwatch.start();
        _currentWpm = 0.0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
      });

      _wpmTimer = Timer.periodic(Duration(seconds: _intervalDuration), (timer) {
        setState(() {
          int wordCount = _countWords(_currentText);
          int elapsedSeconds = _stopwatch.elapsed.inSeconds;
          _currentWpm = _calculateWPM(wordCount, elapsedSeconds);
          _wpmHistory.add(_currentWpm);

          int lowerLimit, upperLimit;
          switch (_selectedPace) {
            case "100-130":
              lowerLimit = 100;
              upperLimit = 130;
              break;
            case "130-160":
              lowerLimit = 130;
              upperLimit = 160;
              break;
            case "160-210":
              lowerLimit = 160;
              upperLimit = 210;
              break;
            default:
              lowerLimit = 0;
              upperLimit = 0;
          }

          if (_currentWpm < lowerLimit) {
            _warningMessage = "You are talking too slow, pick the pace up.";
          } else if (_currentWpm > upperLimit) {
            _warningMessage = "Your talking pace is too fast, go slower.";
          } else {
            _warningMessage = "You are right on track, go on!";
            _withinLimitCount++;
          }
        });
      });

      _speech.listen(
        onResult: (val) {
          setState(() {
            _currentText = val.recognizedWords;
          });
          _scrollToBottom();
        },
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _stopwatch.stop();

      if (_currentText.isNotEmpty) {
        int duration = _stopwatch.elapsed.inSeconds;
        int wordCount = _countWords(_currentText);
        _recognizedParagraphs.add(_currentText + ".");
        _recordingDurations.add(duration);
        _wordCounts.add(wordCount);
        _wpmList.add(_calculateWPM(wordCount, duration));

        if (duration < _intervalDuration) {
          _currentWpm = _calculateWPM(wordCount, duration);
          _wpmHistory.add(_currentWpm);

          int lowerLimit, upperLimit;
          switch (_selectedPace) {
            case "100-130":
              lowerLimit = 100;
              upperLimit = 130;
              break;
            case "130-160":
              lowerLimit = 130;
              upperLimit = 160;
              break;
            case "160-210":
              lowerLimit = 160;
              upperLimit = 210;
              break;
            default:
              lowerLimit = 0;
              upperLimit = 0;
          }

          if (_currentWpm < lowerLimit) {
            _warningMessage = "You are talking too slow, pick the pace up.";
          } else if (_currentWpm > upperLimit) {
            _warningMessage = "Your talking pace is too fast, go slower.";
          } else {
            _warningMessage = "You are right on track, go on!";
            _withinLimitCount++;
          }
        }
      }

      _currentText = "";

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_hasSpeechError) {
          _restartListening();
        }
      });
    });

    _speech.stop();
    _timer.cancel();
    _wpmTimer.cancel();
  }

  void _stopListeningAndNavigate() {
    _stopListening();
    _elapsedStopwatch.stop();

    double averageWpm = _wpmHistory.isNotEmpty
        ? _wpmHistory.reduce((a, b) => a + b) / _wpmHistory.length
        : 0.0;

    double withinLimitPercentage = _wpmHistory.isNotEmpty
        ? (_withinLimitCount / _wpmHistory.length) * 100
        : 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          spokenText: _recognizedParagraphs.join(' '),
          averageWpm: averageWpm,
          withinLimitPercentage: withinLimitPercentage,
        ),
      ),
    );
  }

  void _restartListening() {
    if (!_isListening) {
      _startListening();
    }
  }

  void _restartListeningOnError() {
    if (_isListening) {
      _stopListening();
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isListening) {
        _startListening();
      }
    });
  }

  void _clearScreen() {
    setState(() {
      _recognizedParagraphs.clear();
      _recordingDurations.clear();
      _wordCounts.clear();
      _wpmList.clear();
      _wpmHistory.clear();
      _currentText = "";
      _currentWpm = 0.0;
      _warningMessage = '';
      _paceSelected = false;
      _selectedPace = null;
      _withinLimitCount = 0;
      _listeningSessionCounter = 0;
      _elapsedStopwatch.reset();
    });
  }

  void _startNewSession() {
    _clearScreen();
    _stopwatch.reset();
    _startListening();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getCircleColor() {
    if (_wpmHistory.isEmpty) {
      return Colors.grey;
    }

    int lowerLimit, upperLimit;
    switch (_selectedPace) {
      case "100-130":
        lowerLimit = 100;
        upperLimit = 130;
        break;
      case "130-160":
        lowerLimit = 130;
        upperLimit = 160;
        break;
      case "160-210":
        lowerLimit = 160;
        upperLimit = 210;
        break;
      default:
        lowerLimit = 0;
        upperLimit = 0;
    }

    if (_currentWpm == 0) {
      return Colors.grey;
    } else if (_currentWpm < lowerLimit * 0.95) {
      return Colors.red;
    } else if (_currentWpm > upperLimit * 1.05) {
      return Colors.red;
    } else if (_currentWpm < lowerLimit || _currentWpm > upperLimit) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to Text Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearScreen,
            tooltip: 'Clear Screen',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _paceSelected
                      ? null
                      : () {
                          setState(() {
                            _selectedPace = "100-130";
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paceSelected ? Colors.grey : Colors.blue,
                  ),
                  child: const Text("100-130"),
                ),
                ElevatedButton(
                  onPressed: _paceSelected
                      ? null
                      : () {
                          setState(() {
                            _selectedPace = "130-160";
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paceSelected ? Colors.grey : Colors.green,
                  ),
                  child: const Text("130-160"),
                ),
                ElevatedButton(
                  onPressed: _paceSelected
                      ? null
                      : () {
                          setState(() {
                            _selectedPace = "160-210";
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paceSelected ? Colors.grey : Colors.red,
                  ),
                  child: const Text("160-210"),
                ),
              ],
            ),
          ),
          if (_selectedPace != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Selected Pace: $_selectedPace WPM",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCircleColor(),
                      ),
                    ),
                    Text(
                      formatElapsedTime(_elapsedStopwatch.elapsed),
                      style: const TextStyle(
                        fontSize: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Warnings',
                      hintText: 'Warning messages will appear here',
                    ),
                    controller: TextEditingController(text: _warningMessage),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
                  child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                ),
                FloatingActionButton(
                  onPressed: _startNewSession,
                  tooltip: 'Start New Session',
                  child: const Icon(Icons.replay),
                ),
                FloatingActionButton(
                  onPressed: _stopListeningAndNavigate,
                  tooltip: 'Stop and View Results',
                  child: const Icon(Icons.stop),
                ),
                if (_isListening)
                  FloatingActionButton(
                    onPressed: () {},
                    tooltip: 'Current WPM',
                    child: Text(_currentWpm.toStringAsFixed(2)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
