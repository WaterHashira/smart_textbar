import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smart_textbar/smart_textbar.dart';
import 'package:smart_textbar/textbar.dart';

import 'package:smart_textbar/ex.dart';



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

class texttbar_example extends StatelessWidget {
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

