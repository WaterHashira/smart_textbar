import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextBar extends StatefulWidget {
  String? speaker_language;
  final double volume;
  final double voice_pitch;
  final double rate;

  TextBar({this.speaker_language = 'en-IN' , this.volume = 0.5 , this.voice_pitch = 1.0 , this.rate = 0.5});

  @override
  _TextBarState createState() => _TextBarState();
}

enum TtsState { playing, stopped, paused, continued }

class _TextBarState extends State<TextBar> {
  late FlutterTts flutterTts;
  bool isCurrentLanguageInstalled = false;

  TtsState ttsState = TtsState.stopped;

  String? latest_word_in_textbar; //contains the latest word in the textbar after the latest space

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getEngines();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(widget.volume);
    await flutterTts.setSpeechRate(widget.rate);
    await flutterTts.setPitch(widget.voice_pitch);

    if (latest_word_in_textbar != null) {
      if (latest_word_in_textbar!.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(latest_word_in_textbar!);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      widget.speaker_language = selectedType;
      flutterTts.setLanguage(widget.speaker_language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(widget.speaker_language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  //method that triggers when text in textbar is changed:-
  void _onChange(String text) {
    setState(() {
      latest_word_in_textbar = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Flutter TTS'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  _inputSection(),
                  _futureBuilder(),
                ]))));
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      child: TextField(
        onChanged: (String value) {
          if(value.endsWith(' ')){
            _speak();
            latest_word_in_textbar = null;
          }
          else{
            _stop();
            latest_word_in_textbar = value;
          }

          _onChange(value);
        },
      ));


  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: widget.speaker_language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));
}