import 'dart:math';
import 'dart:ui' as prefix0;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

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

class _SpringSliderState extends State<SpringSlider>
    with TickerProviderStateMixin {
  final double paddingTop = 50.0;
  final double paddingBottom = 50.0;

  SpringySliderController sliderController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sliderController = new SpringySliderController(
      sliderPercent: 0.5,
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    double sliderPercent = sliderController.sliderValue;
    if (sliderController.state == SpringSliderState.springing) {
      sliderPercent = sliderController.springingPercent;
    }

    return SliderDragger(
      paddingBottom: paddingBottom,
      paddingTop: paddingTop,
      sliderController: sliderController,
      child: Stack(
        children: <Widget>[
          new SliderMarks(
            markCount: widget.markCount,
            color: widget.positiveColor,
            backgroundColor: widget.negativeColor,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          new SliderGoo(
            child: new SliderMarks(
              markCount: widget.markCount,
              color: widget.negativeColor,
              paddingTop: paddingTop,
              backgroundColor: widget.positiveColor,
              paddingBottom: paddingBottom,
            ),
            sliderController: sliderController,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          new SliderPoints(
            sliderPercent: sliderController.state == SpringSliderState.dragging
                ? sliderController.draggingPercent
                : sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          ),
          new SliderDebug(
            sliderPercent: sliderController.state == SpringSliderState.dragging
                ? sliderController.draggingPercent
                : sliderPercent,
            paddingTop: paddingTop,
            paddingBottom: paddingBottom,
          )
        ],
      ),
    );
  }
}

class SliderDebug extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  const SliderDebug(
      {Key key, this.sliderPercent, this.paddingTop, this.paddingBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final height = constraints.maxHeight - paddingBottom - paddingTop;

        return new Stack(
          children: <Widget>[
            new Positioned(
              left: 0.0,
              right: 0.0,
              top: height * (1.0 - sliderPercent) + paddingTop,
              child: Container(
                height: 2.0,
                color: Colors.white,
              ),
            )
          ],
        );
      },
    );
  }
}

class SliderDragger extends StatefulWidget {
  final SpringySliderController sliderController;
  final Widget child;
  final double paddingTop;
  final double paddingBottom;

  SliderDragger(
      {this.child, this.sliderController, this.paddingBottom, this.paddingTop});

  @override
  _SliderDraggerState createState() => _SliderDraggerState();
}

class _SliderDraggerState extends State<SliderDragger> {
  double sliderPercent;
  double startDragY;
  double startDragPercent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onPanStart(DragStartDetails details) {
    startDragY = details.globalPosition.dy;
    startDragPercent = widget.sliderController.sliderValue;

    final sliderWidth = context.size.width;
    final sliderLeftPosition = (context.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0))
        .dx;
    final draggingHorizontalPercent =
        (details.globalPosition.dx - sliderLeftPosition) / sliderWidth;

    widget.sliderController.onDragStart(draggingHorizontalPercent);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final dragDistance = startDragY - details.globalPosition.dy;
    final sliderHeight =
        context.size.height - widget.paddingTop - widget.paddingBottom;
    final dragPercent = dragDistance / sliderHeight;

    final sliderWidth = context.size.width;
    final sliderLeftPosition = (context.findRenderObject() as RenderBox)
        .localToGlobal(const Offset(0.0, 0.0))
        .dx;
    final draggingHorizontalPercent =
        (details.globalPosition.dx - sliderLeftPosition) / sliderWidth;


    widget.sliderController.draggingPercents = new Offset(draggingHorizontalPercent, startDragPercent + dragPercent);
  }

  void _onPanEnd(DragEndDetails details) {
    startDragY = null;
    startDragPercent = null;

    widget.sliderController.onDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

class SliderGoo extends StatelessWidget {
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;
  final Widget child;

  const SliderGoo(
      {Key key,
      this.sliderController,
      this.paddingTop,
      this.paddingBottom,
      this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
        // custom CLIP
        clipper: new SliderClipper(
          sliderController: sliderController,
          paddingTop: paddingTop,
          paddingBottom: paddingBottom,
        ),
        child: child);
  }
}

class SliderMarks extends StatelessWidget {
  final int markCount;
  final Color color;
  final Color backgroundColor;
  final double paddingTop;
  final double paddingBottom;

  SliderMarks(
      {this.color,
      this.markCount,
      this.backgroundColor,
      this.paddingBottom,
      this.paddingTop});

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new SliderMarksPainter(
          markCount: markCount,
          markColor: color,
          markThickness: 2.0,
          backgroundColor: backgroundColor,
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
  final Color markColor;
  final Color backgroundColor;
  final double markThickness;
  final double paddingTop;
  final double paddingBottom;
  final double paddingRight;
  final Paint markPaint;
  final Paint backgroundPaint;

  SliderMarksPainter(
      {this.markColor,
      this.markCount,
      this.backgroundColor,
      this.markThickness,
      this.paddingBottom,
      this.paddingRight,
      this.paddingTop})
      : markPaint = new Paint()
          ..color = markColor
          ..strokeWidth = markThickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
        backgroundPaint = new Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(
          0.0,
          0.0,
          size.width,
          size.height,
        ),
        backgroundPaint);

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
  final SpringySliderController sliderController;
  final double paddingTop;
  final double paddingBottom;

  SliderClipper({this.paddingBottom, this.paddingTop, this.sliderController});

  @override
  prefix0.Path getClip(prefix0.Size size) {
    switch (sliderController.state) {
      case SpringSliderState.idle:
        return _clipIdle(size);
      case SpringSliderState.dragging:
        return _clipDragging(size);
      case SpringSliderState.springing:
        return _clipSpringing(size);
    }
  }

  @override
  bool shouldReclip(CustomClipper<prefix0.Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }

  Path _clipIdle(Size size) {
    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingTop) - top;
    final percentFromBottom = 1.0 - sliderController.sliderValue;

    rect.addRect(new Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));

    return rect;
  }

  Path _clipDragging(Size size) {
    Path compositePath = new Path();

    final top = paddingTop;
    final bottom = size.height - paddingBottom;
    final height = bottom - top;
    final basePercentFromBottom = 1.0 - sliderController.sliderValue;
    final dragPercentFromBottom = 1.0 - sliderController.draggingPercent;

    final baseY = top + (basePercentFromBottom * height);
    final leftX = -0.15 * size.width;
    final leftPoint = Point(leftX, baseY);
    final rightX = 1.15 * size.width;
    final rightPoint = Point(rightX, baseY);

    final dragX = sliderController.draggingHorizontalPercent * size.width;
    final dragY = top + (dragPercentFromBottom * height);
    final crestPoint = new Point(dragX, dragY.clamp(top, bottom));

    double excessDrag = 0.0;
    if (sliderController.draggingPercent < 0.0) {
      excessDrag = sliderController.draggingPercent;
    } else if (sliderController.draggingPercent > 1.0) {
      excessDrag = sliderController.draggingPercent - 1.0;
    }

    final baseControlPointWidth = 150.0;
    final thickeningFactor = excessDrag * height * 0.05;
    final controlPointWidth =
        (200.0 * thickeningFactor).abs() + baseControlPointWidth;

    final rect = new Path();
    rect.moveTo(leftPoint.x, leftPoint.y);
    rect.lineTo(rightPoint.x, rightPoint.y);
    rect.lineTo(rightPoint.x, size.height);
    rect.lineTo(leftPoint.x, size.height);
    rect.lineTo(leftPoint.x, leftPoint.y);
    rect.close();

    compositePath.addPath(rect, Offset(0.0, 0.0));

    final curve = Path();
    curve.moveTo(crestPoint.x, crestPoint.y);
    curve.quadraticBezierTo(
      crestPoint.x - controlPointWidth,
      crestPoint.y,
      leftPoint.x,
      leftPoint.y,
    );
    curve.moveTo(crestPoint.x, crestPoint.y);
    curve.quadraticBezierTo(
      crestPoint.x + controlPointWidth,
      crestPoint.y,
      rightPoint.x,
      rightPoint.y,
    );

    curve.lineTo(leftPoint.x, leftPoint.y);
    curve.close();

    if (dragPercentFromBottom > basePercentFromBottom) {
      compositePath.fillType = PathFillType.evenOdd;
    }

    compositePath.addPath(curve, const Offset(0.0, 0.0));

    return compositePath;
  }

  Path _clipSpringing(Size size) {
    Path rect = new Path();

    final top = paddingTop;
    final bottom = size.height;
    final height = (bottom - paddingTop) - top;
    final percentFromBottom = 1.0 - sliderController.springingPercent;

    rect.addRect(new Rect.fromLTRB(
        0.0, top + (percentFromBottom * height), size.width, bottom));

    return rect;
  }
}

class SliderPoints extends StatelessWidget {
  final double sliderPercent;
  final double paddingTop;
  final double paddingBottom;

  const SliderPoints(
      {Key key, this.sliderPercent, this.paddingTop, this.paddingBottom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
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
    );
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

class SpringySliderController extends ChangeNotifier {
  final SpringDescription sliderSpring = new SpringDescription(
    mass: 1.0,
    stiffness: 1000.0,
    damping: 30.0,
  );

  final TickerProvider _vsync;

  SpringSliderState _state = SpringSliderState.idle;

  // Stable slider value.
  double _sliderPercent;

  // Slider value during user drag
  double _draggingPercent;
  // Slider horizontal value during user drag;
  double _draggingHorizontalPercent;

  // when springing to new slider value, this is where the UI is springing from.
  double _springStartPercent;
  // when springing to new slider value, this is where the UI is springing to.
  double _springEndPercent;
  // current slider value during spring effect
  double _springingPercent;
  //physics spring
  SpringSimulation _sliderSpringSimulation;
  // Ticker that computes current spring position based on time.
  Ticker _springTicker;
  // Elapsed time that has passed since the start of the spring
  double _springTime;

  SpringySliderController({
    double sliderPercent = 0.0,
    vsync,
  })  : _vsync = vsync,
        _sliderPercent = sliderPercent;

  void dispose() {
    if (_springTicker != null) {
      _springTicker.dispose();
    }
    super.dispose();
  }

  SpringSliderState get state => _state;

  double get sliderValue => _sliderPercent;

  set sliderValue(double newValue) {
    _sliderPercent = newValue;
    notifyListeners();
  }

  double get draggingPercent => _draggingPercent;

  double get draggingHorizontalPercent => _draggingHorizontalPercent;

  set draggingPercents(Offset draggingPercent) {
    _draggingHorizontalPercent = draggingPercent.dx;
    _draggingPercent = draggingPercent.dy;
    notifyListeners();
  }

  void onDragStart(double draggingHorizontalPercent) {
    if (_springTicker != null) {
      _springTicker
        ..stop()
        ..dispose();
    }

    _state = SpringSliderState.dragging;
    _draggingPercent = _sliderPercent;
    _draggingHorizontalPercent = draggingHorizontalPercent;

    notifyListeners();
  }

  void onDragEnd() {
    _state = SpringSliderState.springing;
    _springingPercent = _sliderPercent;
    _springStartPercent = _sliderPercent;
    _springEndPercent = _draggingPercent.clamp(0.0, 1.0);

    _draggingPercent = null;

    _sliderPercent = _springEndPercent;

    _startSpringing();

    notifyListeners();
  }

  void _startSpringing() {
    _sliderSpringSimulation = new SpringSimulation(
        sliderSpring, _springStartPercent, _springEndPercent, 0.0);

    _springTime = 0.0;

    _springTicker = _vsync.createTicker(_springTick)..start();
  }

  void _springTick(Duration deltaTime) {
    _springTime += deltaTime.inMilliseconds.toDouble() / 1000.0;
    _springingPercent = _sliderSpringSimulation.x(_springTime);

    if (_sliderSpringSimulation.isDone(_springTime)) {
      _springTicker
        ..stop()
        ..dispose();
      _springTicker = null;

      _state = SpringSliderState.idle;
    }

    notifyListeners();
  }

  double get springingPercent => _springingPercent;

  set springingPercent(double newValue) {
    _springingPercent = newValue;
    notifyListeners();
  }
}

enum SpringSliderState {
  idle,
  dragging,
  springing,
}
