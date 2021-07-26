import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smart_textbar/smart_textbar.dart';
import 'package:smart_textbar/textbar.dart';

import 'package:autotrie/autotrie.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_tts/flutter_tts.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //String _platformVersion = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Ex(),
    );
  }
}

class texttbar_example extends StatefulWidget {
  @override
  _texttbar_exampleState createState() => _texttbar_exampleState();
}

class _texttbar_exampleState extends State<texttbar_example> {
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  void permission() async{
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      // We didn't ask for permission yet.
      await Permission.microphone.request();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: MyApp(),
        ),
      ),
    );
  }
}


class Ex extends StatefulWidget {
  @override
  _ExState createState() => _ExState();
}

class _ExState extends State<Ex> {

  String lang = 'hi-IN';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('smart_textbar'),),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextBar(
              blindMode: true,
              voiceToTextMode: true,
              text_color: Colors.black,
              speaker_highlight_color: Colors.red,
              speaker_language: lang,
            ),
            SizedBox(height: 100,),

            Center(child: Text('speaker language: $lang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),)),
          ],
        ),
      ),
    );
  }
}
