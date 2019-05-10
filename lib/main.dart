import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpringySlider',
      theme: new ThemeData(
        primaryColor: Color.fromARGB(255, 34, 34, 34),
        highlightColor: Color.fromARGB(255, 125, 222, 179),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _buildTextButton(String title, bool isOnLight) {
    return new FlatButton(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Text(title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isOnLight
                ? Theme.of(context).highlightColor
                : Theme.of(context).primaryColor,
          )),
      onPressed: () {
        // TODO:
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: new Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: new AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          brightness: Brightness.dark,
          iconTheme: new IconThemeData(color: Theme.of(context).highlightColor),
          leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {
              // TODO:
            },
          ),
          actions: <Widget>[_buildTextButton('settings'.toUpperCase(), true)],
        ),
        body: new Column(
          children: <Widget>[
            new Expanded(
              child: Container(),
            ),
            new Container(
              color: Theme.of(context).highlightColor,
              child: new Row(
                children: <Widget>[
                  _buildTextButton('more'.toUpperCase(), false),
                  new Expanded(child: new Container()),
                  _buildTextButton('stats'.toUpperCase(), false),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
