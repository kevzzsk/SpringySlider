import 'dart:ui' as prefix0;

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
              child: SpringSlider(
                  markCount: 12,
                  positiveColor: Theme.of(context).highlightColor,
                  negativeColor: Theme.of(context).primaryColor),
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

class SpringSlider extends StatefulWidget {
  final int markCount;
  final Color positiveColor;
  final Color negativeColor;

  SpringSlider({this.markCount, this.negativeColor, this.positiveColor});

  @override
  _SpringSliderState createState() => _SpringSliderState();
}

class _SpringSliderState extends State<SpringSlider> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new SliderMarks(
          markCount: widget.markCount,
          color: widget.positiveColor,
          paddingTop: 50.0,
          paddingBottom: 50.0,
        ),
        ClipPath( // custom CLIP
        clipper:  new SliderClipper(),
          child: new Stack(
            children: <Widget>[
              new Container(
                color: widget.positiveColor,
              ),
              new SliderMarks(
                markCount: widget.markCount,
                color: widget.negativeColor,
                paddingTop: 50.0,
                paddingBottom: 50.0,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks(
      {this.color, this.markCount, this.paddingBottom, this.paddingTop});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
          markCount: markCount,
          color: color,
          markThickness: 2.0,
          paddingTop: paddingTop,
          paddingRight: 20.0,
          paddingBottom: paddingBottom),
      child: Container(),
    );
  }
}

class SliderMarksPainter extends CustomPainter {
  final double largeMarkWidth = 30.0;
  final double smallMarkWidth = 10.0;

  final int markCount;
  final Color color;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;

  SliderMarksPainter(
      {this.color,
      this.markCount,
      this.markThickness,
      this.paddingBottom,
      this.paddingRight,
      this.paddingTop})
      : markPaint = new Paint()
          ..color = color
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final paintHeight = size.height - paddingTop - paddingBottom;
    final gap = paintHeight / (markCount - 1);

    for (int i = 0; i < markCount; ++i) {
      double markWidth = smallMarkWidth;
      if (i == 0 || i == markCount - 1) {
        // first or last
        markWidth = largeMarkWidth;
      } else if (i == 1 || i == markCount - 2) {
        // second or second last
        markWidth = prefix0.lerpDouble(
            smallMarkWidth, largeMarkWidth, 0.5); // divide double by 2
      }

      final markY = i * gap + paddingTop;

      canvas.drawLine(new Offset(size.width - paddingRight - markWidth, markY),
          new Offset(size.width - paddingRight, markY), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return null;
  }
}

class SliderClipper extends CustomClipper<Path>{


  @override
  prefix0.Path getClip(prefix0.Size size) {
    Path rect = new Path();

    rect.addRect(
      new Rect.fromLTWH(
        0.0, size.height/2, size.width, size.height)
    );

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<prefix0.Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }

}