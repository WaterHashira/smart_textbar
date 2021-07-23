import 'package:flutter/material.dart';
import 'dart:io';
import 'package:smart_textbar/dictionary.dart';

import 'package:autotrie/autotrie.dart';
import 'package:smart_textbar/AutoSuggest/AutoSuggest_data.dart';

class AutoSuggest_Algo{

  File AutoSuggestTrie = File("../AutoSuggest_data.dart");

  List<String> FirstRunList = [];
  List<String> NotFirstRunList = [];

  var engine = AutoComplete(engine: SortEngine.configMulti(Duration(seconds: 1), 15, 0.5, 0.5));

  /*engineSelecter(bool FirstRun){
    if(FirstRun){
      return AutoComplete(engine: SortEngine.configMulti(Duration(seconds: 1), 15, 0.5, 0.5)); //You can also initialize with a starting databank.
    }
    else{
      return AutoComplete.fromFile(file: AutoSuggestTrie, engine: SortEngine.configMulti(Duration(seconds: 1), 15, 0.5, 0.5)); //You can also initialize with a starting databank.
    }
  }*/

  void populatingTrie(bool FirstRun) async{
    if(FirstRun){
      //var engine = engineSelecter(FirstRun);
      final int dictionaryLength = word_dictionary.length;
      for(int i = dictionaryLength-1 ; i >= 0 ; i--){
        //TODO: ACCORDING TO WRITTEN INN REGISTER
        for(int j=0 ; j < dictionaryLength-i ; j++){
          engine.enter(word_dictionary[i]);
        }
      }
      await engine.persist(AutoSuggestTrie);
    }
    else{
      //var engine = engineSelecter(FirstRun);
      final int dictionaryLength = word_dictionary.length;
      for(int i = dictionaryLength-1 ; i >= 0 ; i--){
        //TODO: ACCORDING TO WRITTEN INN REGISTER
        for(int j=0 ; j < dictionaryLength-i ; j++){
          engine.enter(word_dictionary[i]);
        }
      }
      await engine.persist(AutoSuggestTrie);
    }
  }


  List<String> recommendations (String prefix){
    return engine.suggest(prefix);
  }
}