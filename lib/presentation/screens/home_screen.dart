import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:pingolearn_ass_rexord_search/api/get_search_response.dart';
import 'package:pingolearn_ass_rexord_search/data/search_response.dart';
import 'package:pingolearn_ass_rexord_search/search_provider.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? url = 'https://owlbot.info/api/v4/dictionary';
  String? token = 'Token 055862458bcc01d9604e9559aab727d91d5d2fe4';

  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  String? text = "Enter to speak";
  String? _lastWords = '';
  String? _spokenWord;
  double confidence = 1.0;

  bool _isLoading = false;
  List<Definition> _definitionslist = [];
  SearchResponse? _searchResponse;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _listen() async {
    if (_speechEnabled) {
      bool available = await _speechToText.initialize(
        onStatus: (val) => print("onStatus $val"),
        onError: (val) => print("onerror $val"),
      );
      if (available) {
        setState(() {
          _speechEnabled = true;
        });
        _speechToText.listen(
          onResult: (val) => setState(() {
            text = val.recognizedWords;
            print("spoken word: $text");
            _spokenWord = text;
            // _getDefinitionslistApiCall(_spokenWord ?? '');
            // if (val.hasConfidenceRating && val.confidence > 0) {
            //_confidence = val._confidence;
            // }
          }),
        );
      } else {
        setState(() {
          _speechEnabled = false;
        });
        _speechToText.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SearchProvider(),
      child: Consumer<SearchProvider>(
        builder: ((context, data, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Speech Demo'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Your word:',
                    style: TextStyle(fontSize: 25.0),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      text ?? '',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: !data.isLoading
                          ? [
                              const Text(
                                'Type:',
                                style: TextStyle(fontSize: 25.0),
                              ),
                              Text(
                                data.searchResponse?.definitions?[0].type ??
                                    'No Word',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: Color.fromARGB(255, 188, 194, 195),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Column(children: [
                                  Text(
                                    'Meaning',
                                    style: TextStyle(fontSize: 25.0),
                                  ),
                                  Text(
                                    data.searchResponse?.definitions?[0]
                                            .definition ??
                                        'No Word',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: Color.fromARGB(255, 188, 194, 195),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(children: [
                                    const Text(
                                      'Example',
                                      style: TextStyle(fontSize: 25.0),
                                    ),
                                    Text(
                                      data.searchResponse?.definitions?[0]
                                              .example ??
                                          'No Word',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ])),
                              const SizedBox(height: 10),
                              data.searchResponse?.definitions?[0].imageUrl !=
                                      null
                                  ? Image.network(
                                      data.searchResponse!.definitions![0]
                                          .imageUrl!,
                                      height: 150,
                                      width: 150,
                                    )
                                  : Image.asset(
                                      "assets/images/image_not_found.png",
                                      height: 150,
                                      width: 150,
                                    ),
                            ]
                          : [],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _speechToText.isListening
                            ? '$_lastWords'
                            : _speechEnabled
                                ? 'Tap the microphone to start listening...'
                                : 'Speech not available',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: AvatarGlow(
              endRadius: 80.0,
              animate: _speechEnabled,
              glowColor: Colors.blue,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              showTwoGlows: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              child: FloatingActionButton(
                onPressed: () async {
                  print(
                      "Defntn: ${data.searchResponse?.definitions?[0].definition}");
                  _listen();
                  data.sWord = _spokenWord;
                  if (_speechToText.hasRecognized) {
                    await data.getDefinitionslistApiCall();
                  }
                },
                // onPressed: _speechEnabled ? _startListening : _stopListening,
                tooltip: 'Listen',
                child: Icon(_speechEnabled ? Icons.mic : Icons.mic_off),
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   onPressed:
            //       // If not yet listening for speech start, otherwise stop
            //       _speechToText.isNotListening ? _startListening : _stopListening,
            //   tooltip: 'Listen',
            //   child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            // ),
          );
        }),
      ),
    );
  }
}
