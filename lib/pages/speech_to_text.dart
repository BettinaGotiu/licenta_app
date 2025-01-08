import 'package:flutter/material.dart'; // Biblioteca pentru interfata
import 'package:speech_to_text/speech_to_text.dart'
    as stt; // Biblioteca pentru recunoasterea vocala
import 'dart:async';

// Initializarea si rularea aplicatiei
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
  late Timer _timer;
  late Timer _wpmTimer;

  List<String> _recognizedParagraphs = [];
  List<int> _recordingDurations = [];
  List<int> _wordCounts = [];
  List<double> _wpmList = [];

  double _currentWpm = 0.0;

  final ScrollController _scrollController = ScrollController();

  // New variables for pace selection
  String? _selectedPace;

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

      _wpmTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
        setState(() {
          int wordCount = _countWords(_currentText);
          int elapsedSeconds = _stopwatch.elapsed.inSeconds;
          _currentWpm = _calculateWPM(wordCount, elapsedSeconds);
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
        _recognizedParagraphs.add(_currentText);
        _recordingDurations.add(duration);
        _wordCounts.add(wordCount);
        _wpmList.add(_calculateWPM(wordCount, duration));
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
      _currentText = "";
      _currentWpm = 0.0;
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
          // Pace selection buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPace = "100-130";
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("100-130"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPace = "130-160";
                    });
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("130-160"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedPace = "160-210";
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("160-210"),
                ),
              ],
            ),
          ),
          // Display selected pace
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
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              thickness: 10,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._recognizedParagraphs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final paragraph = entry.value;
                        final duration = _recordingDurations[index];
                        final wordCount = _wordCounts[index];
                        final wpm = _wpmList[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      paragraph,
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        color: Color.fromARGB(255, 147, 70, 70),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Duration: $duration seconds, Words: $wordCount, WPM: ${wpm.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (_currentText.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _currentText,
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Text field for warning messages
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Warnings',
                hintText: 'Warning messages will appear here',
              ),
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
}
