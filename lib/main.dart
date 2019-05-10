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
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  double sliderPercent = 0.5;
  double startDragY;
  double startDragPercent;

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = sliderPercent;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight = context.size.height;
    final dragPercent = dragDistance / sliderHeight;

    setState(() {
      sliderPercent = startDragPercent + dragPercent;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      startDragY = null;
      startDragPercent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: <Widget>[
          new SliderMarks(
            markCount: widget.markCount,
            color: widget.positiveColor,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          ClipPath(
            // custom CLIP
            clipper: new SliderClipper(
              sliderPercent: sliderPercent,
              paddingTop: paddingTop,
              paddingBottom: paddingBottom,
            ),
            child: new Stack(
              children: <Widget>[
                new Container(
                  color: widget.positiveColor,
                ),
                new SliderMarks(
                  markCount: widget.markCount,
                  color: widget.negativeColor,
                  paddingTop: paddingTop,
                  paddingBottom: paddingBottom,
                ),
              ],
            ),
          ),
          new Padding(
            padding: EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final height = constraints.maxHeight;
                final sliderY = height * (1.0 - sliderPercent);
                final pointsYouNeed = (100 * (1.0 - sliderPercent)).round();
                final pointsYouHave = (100 - pointsYouNeed);

                return new Stack(
                  children: <Widget>[
                    new Positioned(
                      left: 30.0,
                      top: sliderY - 50.0,
                      child: FractionalTranslation(
                          translation: Offset(0.0, -1.0),
                          child: new Points(
                            points: pointsYouNeed,
                            isAboveSlider: true,
                            isPointsYouNeed: true,
                            color: Theme.of(context).highlightColor,
                          )),
                    ),
                    new Positioned(
                      left: 30.0,
                      top: sliderY + 50.0,
                      child: new Points(
                        points: pointsYouHave,
                        isAboveSlider: false,
                        isPointsYouNeed: false,
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
    return true;
  }
}

class SliderClipper extends CustomClipper<Path> {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({this.paddingBottom, this.paddingTop, this.sliderPercent});

  @override
  prefix0.Path getClip(prefix0.Size size) {
    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingTop) - top;
    final percentFromBottom = 1.0 - sliderPercent;

    rect.addRect(new Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));

    return rect;
  }

  @override
  bool shouldReclip(CustomClipper<prefix0.Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class Points extends StatelessWidget {
  final int points;
  final bool isAboveSlider;
  final bool isPointsYouNeed;
  final Color color;

  Points({this.color, this.isAboveSlider, this.isPointsYouNeed, this.points});

  @override
  Widget build(BuildContext context) {
    final percent = points / 100.0;
    final pointTextSize = 30.0 + (70.0 * percent);

    return Row(
      crossAxisAlignment:
          isAboveSlider ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        FractionalTranslation(
          translation: Offset(0.0, isAboveSlider ? 0.18 : -0.18),
          child: new Text(
            "$points",
            style: new TextStyle(
              fontSize: pointTextSize,
              color: color,
            ),
          ),
        ),
        new Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'POINTS',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ),
              new Text(isPointsYouNeed ? 'YOU NEED' : 'YOU HAVE',
                  style:
                      new TextStyle(fontWeight: FontWeight.bold, color: color))
            ],
          ),
        )
      ],
    );
  }
}
