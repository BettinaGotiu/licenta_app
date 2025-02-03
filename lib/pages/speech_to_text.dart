import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'results_screen.dart';

class SpeechToTextPage extends StatefulWidget {
  final String selectedPace;
  final String? prompt;

  const SpeechToTextPage({Key? key, required this.selectedPace, this.prompt})
      : super(key: key);

  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage>
    with SingleTickerProviderStateMixin {
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

  String _warningMessage = 'Press the button to start your session';
  final int _intervalDuration = 6;
  int _listeningSessionCounter = 0;

  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 250.0, end: 270.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    setState(() {
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
        _warningMessage =
            ""; // Clear the warning message once the session starts
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
          switch (widget.selectedPace) {
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

          if (_currentWpm < lowerLimit * 0.95 ||
              _currentWpm > upperLimit * 1.05) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.value = 1.0;
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
      _animationController.stop();

      if (_currentText.isNotEmpty) {
        int duration = _stopwatch.elapsed.inSeconds;
        int wordCount = _countWords(_currentText);
        _recognizedParagraphs.add(_currentText + ".\n");
        _recordingDurations.add(duration);
        _wordCounts.add(wordCount);
        _wpmList.add(_calculateWPM(wordCount, duration));

        if (duration < _intervalDuration) {
          _currentWpm = _calculateWPM(wordCount, duration);
          _wpmHistory.add(_currentWpm);

          int lowerLimit, upperLimit;
          switch (widget.selectedPace) {
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

          if (_currentWpm < lowerLimit * 0.95 ||
              _currentWpm > upperLimit * 1.05) {
            _animationController.repeat(reverse: true);
          } else {
            _animationController.stop();
            _animationController.value = 1.0;
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
      _warningMessage = 'Press the button to start your session';
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
      return Color(0xFFa6c6ed); // Default color when no data is available
    }

    int lowerLimit, upperLimit;
    switch (widget.selectedPace) {
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
      return Color(0xFFa6c6ed); // Default color when WPM is 0
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

  Color _getCardBorderColor() {
    if (_wpmHistory.isEmpty) {
      return Colors.black; // Default color when no data is available
    }

    int lowerLimit, upperLimit;
    switch (widget.selectedPace) {
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
      return Colors.black; // Default color when WPM is 0
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        color: Color(0xFFEFF3FE), // Background color of the screen
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0),
              child: _buildRetroCard(
                "Selected Pace: ${widget.selectedPace} WPM",
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: _sizeAnimation.value,
                        height: _sizeAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getCircleColor(),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            formatElapsedTime(_elapsedStopwatch.elapsed),
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 30), // Space between circle and warnings
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 16.0),
                    child: _buildRetroCard(
                      _isListening ? _warningMessage : '$_warningMessage',
                      fontSize:
                          20.0, // Increased font size for better visibility
                      padding: EdgeInsets.all(20.0), // Increased padding
                      borderColor:
                          _getCardBorderColor(), // Dynamic border color
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
                    tooltip:
                        _isListening ? 'Stop Listening' : 'Start Listening',
                    backgroundColor:
                        Color(0xFFB3E5FC), // Light blue color for buttons
                    child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  ),
                  FloatingActionButton(
                    onPressed: _startNewSession,
                    tooltip: 'Start New Session',
                    backgroundColor:
                        Color(0xFFB3E5FC), // Light blue color for buttons
                    child: const Icon(Icons.replay),
                  ),
                  FloatingActionButton(
                    onPressed: _stopListeningAndNavigate,
                    tooltip: 'Stop and View Results',
                    backgroundColor:
                        Color(0xFFB3E5FC), // Light blue color for buttons
                    child: const Icon(Icons.stop),
                  ),
                  if (_isListening)
                    FloatingActionButton(
                      onPressed: () {},
                      tooltip: 'Current WPM',
                      backgroundColor:
                          Color(0xFFB3E5FC), // Light blue color for buttons
                      child: Text(_currentWpm.toStringAsFixed(2)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetroCard(String text,
      {double fontSize = 16.0,
      EdgeInsets padding = const EdgeInsets.all(16.0),
      Color borderColor = Colors.black}) {
    return Container(
      padding: padding,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the cards
        border:
            Border.all(color: borderColor, width: 3), // Dynamic border color
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Offset for shadow
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
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
