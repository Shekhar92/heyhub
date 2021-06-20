import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heyhub/bloc/emoji_bloc.dart';
import 'package:heyhub/model/cat_header_model.dart';
import 'package:heyhub/model/emoji_model.dart';

class CustomDialog extends StatefulWidget {
  const CustomDialog({Key key}) : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final emojiBloc = EmojiBloc();
  List<CatHeaderModel> catHeaderList = new List<CatHeaderModel>();
  List<String> catNameList = new List<String>();
  List<EmojiModel> mainList = new List<EmojiModel>();
  List<EmojiModel> filterEmojiList = new List<EmojiModel>();
  CatHeaderModel _catHeaderModel;

  @override
  void initState() {
    // TODO: implement initState
    emojiBloc.actionSink.add(nAction.FetchEmoji);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emojiBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [catList(), searchEmoji(), emojiSection()],
      ),
    );
  }

  Widget catList() {
    return Container(
      child: StreamBuilder<List<CatHeaderModel>>(
        stream: emojiBloc.urlStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 15,
              child: new ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        emojiBloc.add(EmojiEvent(snapshot.data[index].catName,
                            nAction.FetchFilterList));
                      },
                      child: Container(
                          padding: EdgeInsets.all(10),
                          child: new Text(snapshot.data[index].catSymbol)),
                    );
                  }),
            );
          } else {
            return Text("Loading");
          }
        },
      ),
    );
  }

  Widget searchEmoji() {
    return Column(
      children: [
        Container(
          height: 1,
          decoration: BoxDecoration(color: Colors.indigo),
        ),
        Container(
          height: 65,
            padding: EdgeInsets.all(10),
            child: StreamBuilder(
              stream: emojiBloc.catName,
              builder: (context, AsyncSnapshot<String> snapshot) {
                return TextFormField(
                  onChanged: emojiBloc.changeCatName,
                  initialValue: snapshot.data,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                    ),
                    hintText: "Search",
                  ),
                );
              },
            )),
      ],
    );
  }

  Widget emojiSection() {
    return StreamBuilder(
        stream: emojiBloc.catName,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            emojiBloc.actionSink.add(nAction.FetchFilterList);
          }
          return StreamBuilder(
              stream: emojiBloc.filterStream,
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height / 2,
                      child: GridView.builder(
                          itemCount: snapshot.data.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 10, childAspectRatio: 0.6),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                                onTap: () {
                                  emojiBloc.add(EmojiEvent(snapshot.data[index],
                                      nAction.SelectedEmoji));
                                  // Navigator.pop(context);
                                },
                                child: Text(snapshot.data[index]));
                          }),
                    ),
                  );
                } else {
                  return Text("");
                }
              });
        });
  }
}
