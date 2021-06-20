
class EmojiListModel{
  List<EmojiModel> emojiModel;

}


class EmojiModel {
  String emoji;
  String description;
  String category;
  List<String> aliases;
  List<String> tags;
  String unicodeVersion;
  String iosVersion;

  EmojiModel(
      {this.emoji,
      this.description,
      this.category,
      this.aliases,
      this.tags,
      this.unicodeVersion,
      this.iosVersion});

  EmojiModel.fromJson(Map<String, dynamic> json) {
    emoji = json['emoji'];
    description = json['description'];
    category = json['category'];
    aliases = json['aliases'].cast<String>();
    tags = json['tags'].cast<String>();
    unicodeVersion = json['unicode_version'];
    iosVersion = json['ios_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['emoji'] = this.emoji;
    data['description'] = this.description;
    data['category'] = this.category;
    data['aliases'] = this.aliases;
    data['tags'] = this.tags;
    data['unicode_version'] = this.unicodeVersion;
    data['ios_version'] = this.iosVersion;
    return data;
  }
}
