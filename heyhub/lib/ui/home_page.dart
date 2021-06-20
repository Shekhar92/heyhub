import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heyhub/bloc/emoji_bloc.dart';
import 'package:heyhub/ui/custom_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final emojiBloc = EmojiBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("HomeScreen"),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(
                height: 50,
              ),
              Text("Express your feelings with emojis"),
              RaisedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog();
                      });
                },
                child: Text("Select emoji"),
              ),
              // Here i am trying to get click emoji
              /* Container(
                height: 50,
                child: StreamBuilder(
                  stream: emojiBloc.emojiStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data);
                    } else {
                      return Text("No Data found");
                    }
                  },
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
