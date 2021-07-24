TextFields are a very essential and at the same time a very basic part of any app or website, it may not be a very flashy componenet of the UI, however an app or a website having textfields loaded with essential functionalities can do wonders in regards with the User Experience

# smart_textbar

smart_textbar is a Flutter Plugin that provides an ultimate Flutter textfield, drastically reducing the need to implement various functionalities, that although relatively complex but has become a norm in mordern apps and websites


# Installation

```
dependencies:
  smart_textbar: <latest_version>
```

## Usage

A usage example is provided below. Check the API Reference for detailed docs:

```import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:smart_textbar/smart_textbar.dart';
import 'package:smart_textbar/textbar.dart';

import 'package:autotrie/autotrie.dart';
import 'package:permission_handler/permission_handler.dart';


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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text('here'),
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => TextBar(
              autoCorrect: true,
              blindMode: true,
              voiceToTextMode: true,
            ),));
          },
        ),
      ),
    );
  }
}
```


# Modes

1.**Blind Mode:**
      Blind mode, is made to help the app/website users with sight       disabilities, its basic functionality includes speaking out the latest word written by the user in the **TextBar()** widget,
       the word ending is identified by a blank space, thus letting the user know right away if there is a typo or any grammatical mistake in the text
 
 **How to use Blind Mode?**
 - Set the bool property of the  **TextBar()** widget, **blindMode** as true this would allow all the properties that are included in blindMode to show effect in the widget according to their values.
 - **BlindMode Properties:**  
 
 Property | Data Type | Explanation
------------ | ------------- | -------------
Speaker Language | String? | this decides what language will the speaker speak(choose amoung the language codes available)
volume | double | this will decide the volume of the voice of speaker
voice_pitch | double | this will decide the pitch of the voice of speaker
rate| double | this will decide the rate(speed) of the voice of speaker
speaker_highlight_color| Color| this will decide the color of the words that are currently being spoken by the speaker

2.**Voice To Text Mode:**
voice to text mode is made to convert the words spoken by the user to the text in the **TextBar()** widget

**How to use Voice To Text Mode?**
 - Set the bool property of the  **TextBar()** widget, **voiceToTextMode** as true this would allow all the properties that are included in voiceToTextModeto show effect in the widget according to their values.
 
 - **Voice To Text Mode Properties:**  
 
Property | Data Type | Explanation
------------ | ------------- | -------------
voice_button_icon | Icon | this decides what icon will the suffix iconButton of the TextBar() will have (the listening process to the user voice will start when this button will be pressed )

There are also many Methods available in Voice To Text Mode for various purposes such as, *startListening()*, *stopListening(), cancelListening() * and many more..
(For more information refer to the:  [GitHub Repo](https://github.com/WaterHashira/smart_textbar))


## AutoSuggest

One of the most notable features of smart_textbar is the AutoSuggest functionality, it provides with a dataset of over [10000 most used english words](https://github.com/first20hours/google-10000-english/blob/master/20k.txt) , that are stored in the app in form of a **Trie** 
When **TextBar()** widget is used for the first time in the app by the user, the trie is populated and stored within the app itself which provides a fast and accurate list of recommendations every time user types a new word in the TextBar()


