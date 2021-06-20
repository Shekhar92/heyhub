import 'dart:convert';

import 'package:heyhub/model/emoji_model.dart';
import 'package:heyhub/utils/string.dart';
import 'package:http/http.dart' as http;

class API {
  Future<List<EmojiModel>> getEmojiList() async {
    var client = http.Client();
    var emojiModel;

    try {
      var response = await client.get(Strings.emoji_url);
      if (response.statusCode == 200) {
        var jsonString = response.body;
        List list = json.decode(jsonString);
/*
        emojiModel = EmojiModel.fromJson(list);
*/
        emojiModel = list.map((m) => new EmojiModel.fromJson(m)).toList();
      }
    } catch (Exception) {
      return emojiModel;
    }

    return emojiModel;
  }
}
