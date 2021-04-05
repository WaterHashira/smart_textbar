import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class TextBar extends StatefulWidget {

  //TODO: MAKE ITS CONSTRUCTOR WITH ALL THE PROPERTIES OF  REGULAR TEXTFIELD:-
  final String text;
  final bool autoCorrect;
  final bool autofocus;
  final TextEditingController textController;
  final Color cursorColor;
  final double cursorHeight;
  final Radius cursorRadius;
  final double cursorWidth;
  final TextStyle style;

  var onChanged;

  final InputDecoration decoration;
  final DragStartBehavior dragStartBehavior;

  TextBar({this.text ,this.autoCorrect , this.autofocus , this.textController , this.cursorColor , this.cursorHeight,
    this.cursorRadius , this.cursorWidth ,this.style , this.onChanged ,this.decoration , this.dragStartBehavior});

  @override
  _TextBarState createState() => _TextBarState();
}

class _TextBarState extends State<TextBar> {
  FlutterTts _flutterTts; //instance of flutter tts
  bool is_playing = false; //to know if we need to start the speech or not

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  //method for initialising flutterTts platform handlers:-
  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        print("playing");
        is_playing = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        print("speech completed!");
        is_playing = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        is_playing = false;
      });
    });
  }

  //method for setting the speech language every time the speech is started :-
  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
  }

  //method for selecting the male voice every time the speech is started :-
  void speechSettings1() {
    _flutterTts.setVoice({"name": "Karen", "locale": "en-AU"}); //TODO: CHANGE IT TO A MALE VOICE
    _flutterTts.setPitch(1.5);
    _flutterTts.setSpeechRate(.9);
  }

  //method for selecting the female voice every time the speech is started :-
  void speechSettings2() async{
    await _flutterTts.setVoice({"name": "Karen", "locale": "en-AU"});
    _flutterTts.setPitch(1);
    _flutterTts.setSpeechRate(0.5);
  }

  //method for starting the speech :-
  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          is_playing = true;
        });
    }
  }

  //method for stopping the speech :-
  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        is_playing = false;
      });
  }


  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }

  String textValue;
  var ttsState;

  String last_word; //latest word written in the textbar by the user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextField(
        autocorrect: widget.autoCorrect,
        autofocus: widget.autofocus,
        controller: widget.textController,

        cursorColor: widget.cursorColor,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorWidth: widget.cursorWidth,

        style: widget.style,
        onChanged: (value){
          if(value != ' '){
            setState(() {
              //ttsState = value;
              last_word = last_word + value;
            });
          }
          else{
            setState(() async{
              ttsState = last_word;
              await setTtsLanguage();
              speechSettings1(); //TODO: PROVIDE OPTION FOR CHANGING THE VOICE OF THE SPEAKER TO THE USER
              await _speak(ttsState);
              await _stop();
            });
          }
          widget.onChanged;
        },
        decoration: widget.decoration,
        dragStartBehavior: widget.dragStartBehavior,
      ),
    );
  }
}

