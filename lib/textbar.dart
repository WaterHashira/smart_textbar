import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:math' as Math;
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autotrie/autotrie.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:smart_textbar/AutoSuggest/AutoSuggest_algo.dart';


class TextBar extends StatefulWidget {
  Color text_color;
  var onChanged;
  //IT IS PART OF THE CORRECTION MECHANISM MODE AS WELL:-
  bool autoCorrect;

  //UPPER LEVEL BLIND MODE PARAMETER:-
  final bool blindMode;
  //BLIND MODE PARAMETERS:-
  String? speaker_language;
  final double volume;
  final double voice_pitch;
  final double rate;
  final Color speaker_highlight_color;


  //UPPER LEVEL VOICE TO TEXT MODE PARAMETER:-
  final bool voiceToTextMode;
  //VOICE TO TEXT MODE PARAMETERS:-
  final Icon voice_button_icon;

  //GENERAL PROPERTIES OF TEXTFIELDS:-
  Key? key;
  var controller;
  var focusNode;
  var decoration = const InputDecoration();
  TextInputType? keyboardType;
  var textInputAction;
  var textCapitalization = TextCapitalization.none;
  var style;
  var strutStyle;
  var textAlign = TextAlign.start;
  var textAlignVertical;
  var textDirection;
  var readOnly = false;
  ToolbarOptions? toolbarOptions;
  var showCursor;
  var autofocus = false;
  var obscuringCharacter = '•';
  var obscureText = false;
  var autocorrect = true;
  SmartDashesType? smartDashesType;
      SmartQuotesType? smartQuotesType;
  var enableSuggestions = true;
  var maxLines = 1;
  var minLines;
  var expands = false;
  var maxLength;
  var maxLengthEnforcement;
  var onEditingComplete;
  var onSubmitted;
  var onAppPrivateCommand;
  var inputFormatters;
  var enabled;
  var cursorWidth = 2.0;
  var cursorHeight;
  var cursorRadius;
  var cursorColor;
  var selectionHeightStyle = ui.BoxHeightStyle.tight;
  var selectionWidthStyle = ui.BoxWidthStyle.tight;
  var keyboardAppearance;
  var scrollPadding = const EdgeInsets.all(20.0);
  var dragStartBehavior = DragStartBehavior.start;
  var enableInteractiveSelection = true;
  var onTap;
  var mouseCursor;
  var buildCounter;
  var scrollController;
  var scrollPhysics;
  var autofillHints;
  var specialTextSpanBuilder;
  var selectionControls;
  var restorationId;

  TextBar({this.text_color = Colors.black , this.onChanged ,this.autoCorrect = false ,
    this.blindMode = false , this.speaker_language = 'en-IN' , this.volume = 0.5 , this.voice_pitch = 1.0 , this.rate = 0.5 , this.speaker_highlight_color = Colors.red ,
    this.voiceToTextMode = false , this.voice_button_icon = const Icon(Icons.mic),
    Key? key,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    TextInputType? keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    ToolbarOptions? toolbarOptions,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onEditingComplete,
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.mouseCursor,
    this.buildCounter,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints,
    this.specialTextSpanBuilder,
    this.selectionControls,
    this.restorationId,
  });

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


  //POPULATING THE TRIE FOR THE FIRST TIME IF THE APP IS BEING OPENED FOR THE FIRST TIME EVER
  //IN THE DEVICE WHICH GETS PERSISTED IN THE AutoSuggest_data FILE THAT MEANS WE ONLY NEED TO
  //POPULATE THE TRIE IF THE APP IS RUN FOR THE FIRST TIME ON THE DEVICE.

  bool first_run = true;
  SpeechToText speech = SpeechToText();
  @override
  initState() {
    speech = SpeechToText();
    super.initState();
    if(isFirstTime() == true){
      first_run = true;
      print('its the first run');
      //AutoSuggest_Algo().populatingTrie(first_run);
    }
    else{
      first_run = false;
      print('its not the first run');
    }
    initTts();
  }

  //METHOD FOR CHECKING WHETHER THE APP IS OPENED FOR THE FIRST TIME OR NOT:-
  Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isFirstTime = prefs.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      prefs.setBool('first_time', false);
      return true;
    } else {
      await prefs.setBool('first_time', false);
      return false;
    }
  }

  //TEXT TO SPEECH (TTS) METHODS:-
  initTts() {
    flutterTts = FlutterTts();

    if (isAndroid) {
      _getEngines();
    }

    Color general_text_color = widget.text_color;

    //called when speaker starts speaking:-
    flutterTts.setStartHandler(() {
      setState(() {
        widget.text_color = widget.speaker_highlight_color;
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    //called when speaker completes speaking:-
    flutterTts.setCompletionHandler(() {
      setState(() {
        widget.text_color = general_text_color;
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    //called when speaking process is cancelled in between:-
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

    //called when we want to continue the ongoing process of speaking:-
      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    //called when speaking process have an error:-
    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  //Method for getting a list of all the available languages for blind mode:-
  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  //METHOD FOR START SPEAKING AND RELATED FUNCTIONALITIES:-
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

  //for getting getLanguageDropDownMenuItems:-
  /*List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  //method for changing the language selected form the dropdown:-
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
  }*/

  //method that triggers when text in textfield is changed:-
  void _onChange(String text) {
    var temp_word_list;
    setState(() {
      temp_word_list = text.split(" ");
      print(temp_word_list);
      latest_word_in_textbar = temp_word_list[temp_word_list.length - 1];
      print(latest_word_in_textbar);
    });
  }

  //VOICE TO TEXT MODE FUNCTIONALITY:-
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  List<LocaleName> _localeNames = [];

  String stt_text = ''; //variable where stt text is stored

  bool isListening = false; //variable for knowing whether it is still listening or not
  var hasSpeech;

  Future<void> initSpeechState() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (val) => setState(() {
            stt_text = val.recognizedWords;

          }),
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }


  //Method for starting the listening process:-
  void startListening() {
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  //Method for stopping the ongoing listening process:-
  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  //Method for canceling the ongoing listening process:-
  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  //Method for listening to the stt result:-
  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      stt_text = result.recognizedWords;
    });
  }

  //Method for changing the speech volume of the stt speacker:-
  void soundLevelListener(double level) {
    minSoundLevel = Math.min(minSoundLevel, level);
    maxSoundLevel = Math.max(maxSoundLevel, level);
    print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  //Method for handling the stt errors:-
  void errorListener(SpeechRecognitionError error) {
    print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  //Method for listening to the status of stt:-
  void statusListener(String status) {
    // print(
    // 'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  //Method for switching the speaker's language:-
  void _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

//BUILD (UI) IMPLEMENTATION:-
  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) {
          if (widget.blindMode == true && widget.voiceToTextMode == false) {
            return _inputSection_blind_mode();
          }
          else
          if (widget.blindMode == false && widget.voiceToTextMode == true) {
            return _inputSection_voice_to_text_mode();
          }
          else if (widget.blindMode == true && widget.voiceToTextMode == true) {
            return _inputSection_all_mode();
          }
          else {
            return _inputSection();
          }
        }
    );
  }

  /*Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });*/


  //value of the text field will be stored in this widget:-
  String? text_field_value;
  //THIS METHOD HANDELS THE TEXT FIELD WORKING WITHOUT ANY MODE ON:-
  Widget _inputSection() => Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),

    child: TypeAheadField(
      //it contains all the config of a textfield:-

      key: widget.key,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: widget.onTap,

        decoration: widget.decoration,
        onChanged: widget.onChanged,
      ),

      suggestionsCallback: (prefix){
        List<String> recommendations_list; //contains all the recommendations for the specified prefix
        recommendations_list = AutoSuggest_Algo().recommendations(prefix);
        return recommendations_list;
      },
      itemBuilder: (context, suggestions) {
        if(suggestions != null){
          return ListTile(
            title: Text(suggestions.toString()),
          );
        }
        else{
          return ListTile();
        }
      },
      onSuggestionSelected: (suggestions) {
        setState(() {
          text_field_value = suggestions.toString();  //TODO; APPLY onSuggestionSelected WHEN WE SELECT A OPTION IT MUST APPEAR ON THE TEXTFIELD ITSELF
        });
      },

    ),
  );



  //THIS METHOD HANDELS THE TEXT FIELD WORKING OF THE BLIND MODE:-
  Widget _inputSection_blind_mode() => Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),

    child: TypeAheadField(
      //it contains all the config of a textfield:-

      key: widget.key,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: widget.onTap,

        decoration: widget.decoration,
        //for blind mode functionalities:-
        onChanged: (text_field_value) async{
          flutterTts.setLanguage(widget.speaker_language!);
          if(text_field_value.endsWith(' ')){
            await _speak();
            latest_word_in_textbar = null;
          }
          else{
            _stop();
          }
          _onChange(text_field_value);
        },
      ),

      suggestionsCallback: (prefix){
        List<String> recommendations_list; //contains all the recommendations for the specified prefix
        recommendations_list = AutoSuggest_Algo().recommendations(prefix);
        return recommendations_list;
      },
      itemBuilder: (context, suggestions) {
        if(suggestions != null){
          return ListTile(
            title: Text(suggestions.toString()),
          );
        }
        else{
          return ListTile();
        }
      },
      onSuggestionSelected: (suggestions) {
        setState(() {
          text_field_value = suggestions.toString();  //TODO; APPLY onSuggestionSelected WHEN WE SELECT A OPTION IT MUST APPEAR ON THE TEXTFIELD ITSELF
        });
      },

    ),
  );




  //for showing all the language options available for the user
  /*Widget _languageDropDownSection(dynamic languages) => Container(
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
      ]));*/




  //THIS METHOD HANDELS THE TEXT FIELD WORKING OF THE VOICE TO TEXT MODE :-
  Widget _inputSection_voice_to_text_mode() => Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),

    child: TypeAheadField(
      //it contains all the config of a textfield:-

      key: widget.key,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: widget.onTap,

        decoration: InputDecoration(
          //for stt functionality:-
          suffixIcon: IconButton(
            onPressed: _hasSpeech ? null : initSpeechState,
            icon: widget.voice_button_icon,
          ),
        ),
        //for blind mode functionalities:-
        onChanged: widget.onChanged,
      ),

      suggestionsCallback: (prefix){
        List<String> recommendations_list; //contains all the recommendations for the specified prefix
        recommendations_list = AutoSuggest_Algo().recommendations(prefix);
        return recommendations_list;
      },
      itemBuilder: (context, suggestions) {
        if(suggestions != null){
          return ListTile(
            title: Text(suggestions.toString()),
          );
        }
        else{
          return ListTile();
        }
      },
      onSuggestionSelected: (suggestions) {
        setState(() {
          text_field_value = suggestions.toString();  //TODO; APPLY onSuggestionSelected WHEN WE SELECT A OPTION IT MUST APPEAR ON THE TEXTFIELD ITSELF
        });
      },
    ),
  );




  //THIS METHOD HANDELS THE TEXT FIELD WORKING OF THE BOTH BLIND MODE AND VOICE TO TEXT MODE TOGETHER:-
Widget _inputSection_all_mode() => Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),

    child: TypeAheadField(
      //it contains all the config of a textfield:-

      key: widget.key,
      textFieldConfiguration: TextFieldConfiguration(
        controller: widget.controller,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        onTap: widget.onTap,

        decoration: InputDecoration(
          //for stt functionality:-
            suffixIcon: IconButton(
              onPressed: _hasSpeech ? null : initSpeechState,
              icon: widget.voice_button_icon,
            ),
        ),
        //for blind mode functionalities:-
        onChanged: (text_field_value) async{
          flutterTts.setLanguage(widget.speaker_language!);
          if(text_field_value.endsWith(' ')){
            await _speak();
            latest_word_in_textbar = null;
          }
          else{
            _stop();
          }
          _onChange(text_field_value);
        },
      ),

        suggestionsCallback: (prefix){
        List<String> recommendations_list; //contains all the recommendations for the specified prefix
        recommendations_list = AutoSuggest_Algo().recommendations(prefix);
        return recommendations_list;
      },
        itemBuilder: (context, suggestions) {
          if(suggestions != null){
            return ListTile(
              title: Text(suggestions.toString()),
            );
          }
          else{
            return ListTile();
          }
        },
        onSuggestionSelected: (suggestions) {
             setState(() {
                text_field_value = suggestions.toString();  //TODO; APPLY onSuggestionSelected WHEN WE SELECT A OPTION IT MUST APPEAR ON THE TEXTFIELD ITSELF
             });
          },

    ),
);

}