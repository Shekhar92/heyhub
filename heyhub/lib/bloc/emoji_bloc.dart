import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heyhub/model/cat_header_model.dart';
import 'package:heyhub/model/emoji_model.dart';
import 'package:heyhub/resources/api.dart';
import 'package:heyhub/utils/string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum nAction {
  FetchEmoji,
  FetchSingleEmoji,
  FetchFilterList,
  SelectedEmoji,
  SearchEmojiList
}

class EmojiEvent {
  final String value;
  final nAction status;

  EmojiEvent(this.value, this.status);
}

class EmojiBloc extends Bloc<EmojiEvent, String> {
  // Search category
  final _catName = BehaviorSubject<String>();

  Observable<String> get catName => _catName.stream.transform(_validateCatName);

  Function(String) get changeCatName => _catName.sink.add;

  // Category Header
  final _stateStreamController = StreamController<List<CatHeaderModel>>();

  StreamSink<List<CatHeaderModel>> get newSink => _stateStreamController.sink;

  Stream<List<CatHeaderModel>> get urlStream => _stateStreamController.stream;

  // Based on Action will send to widget
  final _actionStreamController = StreamController<nAction>();

  StreamSink<nAction> get actionSink => _actionStreamController.sink;

  Stream<nAction> get _actionSteam => _actionStreamController.stream;

  // Filter List controller for search and on category click
  final _filterEmojiStreamController = StreamController<List<String>>();

  StreamSink<List<String>> get filterSink => _filterEmojiStreamController.sink;

  Stream<List<String>> get filterStream => _filterEmojiStreamController.stream;

  // For gridview item
  final _emojiIndexStreamController = StreamController<String>();

  StreamSink<String> get emojiSink => _emojiIndexStreamController.sink;

  Stream<String> get emojiStream => _emojiIndexStreamController.stream;

/*  final _searchEmojiStreamController = StreamController<String>();
  StreamSink<String> get searchEmojiSink => _searchEmojiStreamController.sink;
  Stream<String> get searchEmojiStream => _searchEmojiStreamController.stream;*/

  // Main list
  List<EmojiModel> emojiList = new List<EmojiModel>();

  // FliterList after serch and category click
  List<String> filterEmojiList = new List<String>();

  // Header category list
  List<CatHeaderModel> catHeaderList = new List<CatHeaderModel>();

  List<String> catNameList = new List<String>();
  List<String> localEmojiList = new List<String>();

  // var emoji = String;

  // this constructor call just for events
  EmojiBloc() : super('') {
    _actionSteam.listen((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        if (event == nAction.FetchEmoji) {
          var tempEmojiList = await API().getEmojiList();
          if (tempEmojiList != null) emojiList.addAll(tempEmojiList);
          for (int i = 0; i < emojiList.length; i++) {
            if (catHeaderList.isEmpty) {
              if (prefs.containsKey("localList")) {
                catNameList.add("recent");
                catHeaderList.add(CatHeaderModel("recent", "🕛"));
              } else {
                catNameList.add(emojiList[i].category);
                catHeaderList.add(
                    CatHeaderModel(emojiList[i].category, emojiList[i].emoji));
              }
            } else if (catNameList.contains(emojiList[i].category)) {
              // Do nothing
            } else {
              catNameList.add(emojiList[i].category);
              catHeaderList.add(
                  CatHeaderModel(emojiList[i].category, emojiList[i].emoji));
            }
          }
          newSink.add(catHeaderList);
        }

        // On grid view item click will get that emoji
        /* if (event == nAction.SelectedEmoji) {
          emojiSink.add(emoji.toString());
        }*/

        if (event == nAction.FetchFilterList) {
          filterEmojiList.clear();
          if (_catName.value.contains("recent")) {
            localEmojiList = prefs.getStringList("localList");
            for (int i = 0; i < localEmojiList.length; i++) {
              filterEmojiList.add(localEmojiList[i]);
            }
          } else {
            for (int i = 0; i < emojiList.length; i++) {
              if (emojiList[i].description.contains(_catName.value) ||
                  emojiList[i].aliases.contains(_catName.value) ||
                  emojiList[i].tags.contains(_catName.value)) {
                if (filterEmojiList.isEmpty) {
                  filterEmojiList.add(emojiList[i].emoji);
                } else {
                  filterEmojiList.add(emojiList[i].emoji);
                }
              }
            }
          }
          filterSink.add(filterEmojiList);
        }
      } on Exception catch (e) {
        newSink.addError("Something went wrong");
        // TODO
      }
    });
  }

  //Validation
  final _validateCatName = StreamTransformer<String, String>.fromHandlers(
      handleData: (catName, sink) {
    if (catName == " ") {
      sink.addError(Strings.errorCatName);
    } else {
      sink.add(catName);
    }
  });

  // This method dispose all controllers after screen close.
  void dispose() {
    _catName.drain();
    _catName.close();
    _stateStreamController.close();
    _actionStreamController.close();
    _filterEmojiStreamController.close();
    _emojiIndexStreamController.close();
  }

  // This method use on item click on list and gridview to get item value
  @override
  Stream<String> mapEventToState(EmojiEvent event) async* {
    // TODO: implement mapEventToState
    if (event.status == nAction.FetchEmoji) {
      var tempEmojiList = await API().getEmojiList();
      if (tempEmojiList != null)
        // newSink.add(tempEmojiList);
        emojiList.addAll(tempEmojiList);
    }

    if (event.status == nAction.FetchFilterList) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      filterEmojiList.clear();
      if (event.value.contains("recent")) {
        localEmojiList = prefs.getStringList("localList");
        for (int i = 0; i < localEmojiList.length; i++) {
          filterEmojiList.add(localEmojiList[i]);
        }
      } else {
        for (int i = 0; i < emojiList.length; i++) {
          if (event.value.contains(emojiList[i].category)) {
            filterEmojiList.add(emojiList[i].emoji);
          }
        }
      }
      filterSink.add(filterEmojiList);
    }

    if (event.status == nAction.SelectedEmoji) {
      emojiSink.add(event.value);
      bool isPresent = false;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (localEmojiList.length >= 45) {
        localEmojiList.removeAt(44);
      }
      for (int i = 0; i < localEmojiList.length; i++) {
        if (event.value.contains(localEmojiList[i])) {
          isPresent = true;
        }
      }
      if (isPresent = false) {
        localEmojiList.add(event.value);
      }

      prefs.setStringList("localList", localEmojiList);
      // emoji == event.value;
    }
  }
}
