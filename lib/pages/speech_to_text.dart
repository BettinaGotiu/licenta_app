import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

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
  Timer? _timer;
  Timer? _wpmTimer;

  List<String> _recognizedParagraphs = [];
  List<int> _recordingDurations = [];
  List<int> _wordCounts = [];
  List<double> _wpmList = [];

  double _currentWpm = 0.0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() {
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _stopListening();
    _speech.stop();
    _timer?.cancel();
    _wpmTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  int _countWords(String text) {
    return text.split(RegExp(r'\s+')).length;
  }

  double _calculateWPM(int wordCount, int duration) {
    if (duration == 0) return 0;
    return (wordCount / duration) * 60;
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint("Status: $status");
        if (status == "done" && _isListening) {
          _stopListening();
        }
      },
      onError: (error) {
        debugPrint("Error: ${error.errorMsg}, permanent: ${error.permanent}");
        if (error.errorMsg == "error_speech_timeout" && _isListening) {
          _restartListeningOnError();
        } else if (error.errorMsg == "error_no_match") {
          _restartListeningOnError();
        }
      },
    );

    if (available) {
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _currentText = "";
        _hasSpeechError = false;
        _stopwatch.reset();
        _stopwatch.start();
        _currentWpm = 0.0;
      });

      debugPrint("Starting timers...");
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {});
      });

      _wpmTimer?.cancel();
      _wpmTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
        if (!mounted) return;
        setState(() {
          int wordCount = _countWords(_currentText);
          int elapsedSeconds = _stopwatch.elapsed.inSeconds;
          _currentWpm = _calculateWPM(wordCount, elapsedSeconds);
        });
      });

      _speech.listen(
        onResult: (val) {
          if (!mounted) return;
          setState(() {
            _currentText = val.recognizedWords;
            debugPrint("Recognized words: $_currentText");
          });
          _scrollToBottom();
        },
        listenMode: stt.ListenMode.dictation,
      );
    } else {
      debugPrint("Speech recognition not available");
    }
  }

  void _stopListening() {
    if (_isListening) {
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

      debugPrint("Stopping timers...");
      _speech.stop();
      _timer?.cancel();
      _wpmTimer?.cancel();
    }
  }

  void _restartListening() {
    if (!_isListening) {
      debugPrint("Restarting listening...");
      _startListening();
    }
  }

  void _restartListeningOnError() {
    if (_isListening) {
      _stopListening();
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isListening) {
        debugPrint("Restarting listening on error...");
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

  void _endSession() {
    _stopListening();
    _clearScreen();
    Navigator.pop(context);
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
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _endSession,
            tooltip: 'End Session',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'mic',
                  onPressed: _isListening ? _stopListening : _startListening,
                  tooltip: _isListening ? 'Stop Listening' : 'Start Listening',
                  child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                ),
                FloatingActionButton(
                  heroTag: 'new-session',
                  onPressed: _startNewSession,
                  tooltip: 'Start New Session',
                  child: const Icon(Icons.replay),
                ),
                if (_isListening)
                  FloatingActionButton(
                    heroTag: 'wpm',
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
