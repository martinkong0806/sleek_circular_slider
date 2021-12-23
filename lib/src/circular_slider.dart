library circular_slider;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/src/slider_animations.dart';

import 'appearance.dart';
import 'slider_label.dart';
import 'utils.dart';

part 'curve_painter.dart';
part 'custom_gesture_recognizer.dart';

typedef void OnChange(double startPoint, double endPoint, int state);
typedef Widget InnerWidget(double percentage);

class SleekCircularSlider extends StatefulWidget {
  final double initialStart;
  final double initialValue;
  final double min;
  final double max;
  final bool touchOnTrack;
  final CircularSliderAppearance appearance;
  final OnChange? onChange;
  final OnChange? onChangeStart;
  final OnChange? onChangeEnd;
  final InnerWidget? innerWidget;

  final List<double>? externalRestrictions;
  static const defaultAppearance = CircularSliderAppearance();


  double get startOffset {
    return valueToAngle(initialStart, min, max, appearance.angleRange);
  }
  double get angle {
    return valueToAngle(initialValue, min, max, appearance.angleRange);
  }

  const SleekCircularSlider(
      {Key? key,
      this.initialStart = 0,
      this.initialValue = 50,
      this.min = 0,
      this.max = 100,
      this.touchOnTrack = true,
      this.appearance = defaultAppearance,
      this.onChange,
      this.onChangeStart,
      this.onChangeEnd,
      this.innerWidget,
      this.externalRestrictions
      })
      : assert(min <= max),
        assert(initialValue >= min && initialValue <= max),
        super(key: key);
  @override
  _SleekCircularSliderState createState() => _SleekCircularSliderState();
}

class _SleekCircularSliderState extends State<SleekCircularSlider>
    with SingleTickerProviderStateMixin {
  // bool _isHandlerSelected = false;

  // _handleState = 0 : no validate gesture detected
  // 1 : moving start handler
  // 2 : moveing end handler
  int _handleState = 0;

  bool _animationInProgress = false;
  _CurvePainter? _painter;
  double? _oldWidgetAngle;
  double? _oldWidgetValue;
  double? _currentAngle;
  late double _startAngle;
  late double _startAngleOffset;
  late double _angleRange;
  late List<double> _positionOnChangeStart;
  double? _selectedAngle;
  double? _rotation;
  SpinAnimationManager? _spinManager;
  ValueChangedAnimationManager? _animationManager;
  late int _appearanceHashCode;

  bool get _interactionEnabled => (widget.onChangeEnd != null ||
      widget.onChange != null && !widget.appearance.spinnerMode);

  @override
  void initState() {
    super.initState();
    _startAngleOffset = widget.startOffset;
    _startAngle = widget.appearance.startAngle;
    _angleRange = widget.appearance.angleRange;
    _appearanceHashCode = widget.appearance.hashCode;

    _currentAngle = calculateAngle(
        startAngle: _startAngle,
        angleRange: _angleRange,
        selectedAngle: degreeToRadians( (widget.angle + _startAngle)%360),
        defaultAngle: _currentAngle ?? widget.angle,
        counterClockwise: false);


    if (!widget.appearance.animationEnabled) {
      return;
    }

    widget.appearance.spinnerMode ? _spin() : _animate();
  }

  @override
  void didUpdateWidget(SleekCircularSlider oldWidget) {
    _setupPainter(passive: true);

    if (oldWidget.angle != widget.angle &&
        _currentAngle?.toStringAsFixed(4) != widget.angle.toStringAsFixed(4)) {
      _animate();
    }

    super.didUpdateWidget(oldWidget);
  }

  void _animate() {

    if (!widget.appearance.animationEnabled || widget.appearance.spinnerMode) {
      _setupPainter();
      _updateOnChange();
      return;
    }
    if (_animationManager == null) {

      _animationManager = ValueChangedAnimationManager(
        tickerProvider: this,
        minValue: widget.min,
        maxValue: widget.max,
        durationMultiplier: widget.appearance.animDurationMultiplier,
      );
    }

    _oldWidgetAngle = widget.startOffset;

    _animationManager!.animate(
        initialValue: widget.initialValue,
        angle: widget.angle,
        oldAngle: _oldWidgetAngle,
        oldValue: _oldWidgetValue,
        valueChangedAnimation: ((double anim, bool animationCompleted) {
          _animationInProgress = !animationCompleted;

          setState(() {
            if (!animationCompleted) {
              _currentAngle = anim;
              // update painter and the on change closure
              _setupPainter();
              _updateOnChange();
            }
          });
        }));
    // _oldWidgetAngle = widget.angle;
    // _oldWidgetValue = widget.initialValue;
  }

  void _spin() {
    _spinManager = SpinAnimationManager(
        tickerProvider: this,
        duration: Duration(milliseconds: widget.appearance.spinnerDuration),
        spinAnimation: ((double anim1, anim2, anim3) {
          setState(() {
            _rotation = anim1;
            _startAngle = math.pi * anim2;
            _currentAngle = anim3;
            _setupPainter();
            _updateOnChange();
          });
        }));
    _spinManager!.spin();
  }

  @override
  Widget build(BuildContext context) {
    /// _setupPainter excution when _painter is null or appearance has changed.
    if (_painter == null || _appearanceHashCode != widget.appearance.hashCode) {
      _appearanceHashCode = widget.appearance.hashCode;
      _setupPainter();
    }
    return RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          _CustomPanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<_CustomPanGestureRecognizer>(
            () => _CustomPanGestureRecognizer(
              onPanDown: _onPanDown,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
            (_CustomPanGestureRecognizer instance) {},
          ),
        },
        child: _buildRotatingPainter(
            rotation: _rotation,
            size: Size(widget.appearance.size, widget.appearance.size)));
  }

  @override
  void dispose() {
    _spinManager?.dispose();
    _animationManager?.dispose();
    super.dispose();
  }

  void _setupPainter({bool counterClockwise = false, bool passive = false}) {
    var defaultAngle = _currentAngle ?? widget.angle;
    if (_oldWidgetAngle != null) {
      if (_oldWidgetAngle != widget.angle) {
        _selectedAngle = null;
        defaultAngle = widget.angle;
      }
    }
    /// This code will only occurs when external sliders is
    /// affecting this slider
    if (passive){
      _startAngleOffset = calculateAngle(
          startAngle: _startAngle,
          angleRange: _angleRange,
          selectedAngle: degreeToRadians( (widget.startOffset + _startAngle)%360),
          defaultAngle: defaultAngle,
          counterClockwise: counterClockwise);
    }
    /// calculate the angle derived from the gesture.
    double gestureCalcAngle = calculateAngle(
        startAngle: _startAngle,
        angleRange: _angleRange,
        selectedAngle: _selectedAngle,
        defaultAngle: defaultAngle,
        counterClockwise: counterClockwise);

    if (_handleState == 2) {
      if (
      // Only allows movement within a defined degree, this prevent
      // the slider width increase to the maximum value if the slider
      // approaches zero
      ((gestureCalcAngle-_startAngleOffset) % 360 > 20)
          && (( _currentAngle! - gestureCalcAngle ).abs() % 360< 20 || (_currentAngle! - gestureCalcAngle ).abs() % 360>340)
      ) {
        if(widget.externalRestrictions!=null){
          if((gestureCalcAngle-widget.externalRestrictions![1]).abs()<=20){
          }else{
            _currentAngle = gestureCalcAngle;
          }
        }else{
          _currentAngle = gestureCalcAngle ;
        }


      }
    }


    if (_handleState == 1) {
      double angle = calculateAngle(
          startAngle: _startAngle,
          angleRange: _angleRange,
          selectedAngle: _selectedAngle,
          defaultAngle: defaultAngle,
          counterClockwise: counterClockwise);


      if (((_currentAngle! - angle) % 360 > 20)
          && ((angle - _startAngleOffset ).abs() % 360< 20 || (angle - _startAngleOffset ).abs() % 360>340)
      ) {
        if(widget.externalRestrictions!=null){
          if((angle-widget.externalRestrictions![0]).abs()<=20){
          }else{
            _startAngleOffset = angle;
          }
        }else{
          _startAngleOffset = angle;
        }


      }else{
      }



    }


    _painter = _CurvePainter(
        startAngle: _startAngle,
        startAngleOffset: _startAngleOffset,
        angleRange: _angleRange,
        angle: _currentAngle! < 0.5 ? 0.5 : _currentAngle!,
        appearance: widget.appearance);
    _oldWidgetAngle = widget.angle;
    _oldWidgetValue = widget.initialValue;

  }

  void _updateOnChange() {
    if (widget.onChange != null && !_animationInProgress) {
      final value =
          angleToValue(_currentAngle!, widget.min, widget.max, _angleRange);
      widget.onChange!(
          angleToValue(_startAngleOffset, widget.min, widget.max, _angleRange),
          value,
          _handleState);
    }
  }

  Widget _buildRotatingPainter({double? rotation, required Size size}) {
    if (rotation != null) {
      return Transform(
          transform: Matrix4.identity()..rotateZ((rotation) * 5 * math.pi / 6),
          alignment: FractionalOffset.center,
          child: _buildPainter(size: size));
    } else {
      return _buildPainter(size: size);
    }
  }

  Widget _buildPainter({required Size size}) {
    return CustomPaint(
        painter: _painter,
        child: Container(
            width: size.width,
            height: size.height,
            child: _buildChildWidget()));
  }

  Widget? _buildChildWidget() {
    if (widget.appearance.spinnerMode) {
      return null;
    }
    final value =
        angleToValue(_currentAngle!, widget.min, widget.max, _angleRange);
    final childWidget = widget.innerWidget != null
        ? widget.innerWidget!(value)
        : SliderLabel(
            value: value,
            appearance: widget.appearance,
          );
    return childWidget;
  }

  void _onPanUpdate(Offset details) {
    if (_handleState == 0) {
      return;
    }
    if (_painter?.center == null) {
      return;
    }
    _handlePan(details, false);
  }

  void _onPanEnd(Offset details) {
    _handlePan(details, true);
    if (widget.onChangeEnd != null) {
      widget.onChangeEnd!(
          angleToValue(_startAngleOffset, widget.min, widget.max, _angleRange),
          angleToValue(_currentAngle!, widget.min, widget.max, _angleRange),
          _handleState);
    }

    _handleState = 0;
  }

  void _handlePan(Offset details, bool isPanEnd) {
    if (_painter?.center == null) {
      return;
    }

    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);
    final double touchWidth = widget.appearance.progressBarWidth >= 25.0
        ? widget.appearance.progressBarWidth
        : 25.0;

    if (isPointAlongCircle(
        position, _painter!.center!, _painter!.radius, touchWidth)) {}

    _selectedAngle = coordinatesToRadians(_painter!.center!, position);

    // setup painter with new angle values and update onChange
    _setupPainter(counterClockwise: widget.appearance.counterClockwise);
    _updateOnChange();
    setState(() {});
  }

  bool _onPanDown(Offset details) {
    if (_painter == null || _interactionEnabled == false) {
      return false;
    }
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var position = renderBox.globalToLocal(details);

    final angleWithinRange = isAngleWithinRange(
        startAngle: _startAngle,
        angleRange: _angleRange,
        touchAngle: coordinatesToRadians(_painter!.center!, position),
        previousAngle: _currentAngle,
        counterClockwise: widget.appearance.counterClockwise);


    if (!angleWithinRange) {
      return false;
    }



    final double touchWidth = widget.appearance.progressBarWidth >= 25.0
        ? widget.appearance.progressBarWidth
        : 25.0;

    //     ? widget.appearance.progressBarWidth
    //     : 25.0;

    if (!widget.touchOnTrack) {
      _handleState = getHandle(position, touchWidth);
    }

    if (isPointAlongCircle(
        position, _painter!.center!, _painter!.radius, touchWidth)) {
      _handleState = getHandle(position, touchWidth);
      if (widget.onChangeStart != null) {
        widget.onChangeStart!(
            angleToValue(
                _startAngleOffset, widget.min, widget.max, _angleRange),
            angleToValue(_currentAngle!, widget.min, widget.max, _angleRange),
            _handleState);
      }

      _positionOnChangeStart = [_startAngleOffset, _currentAngle!];
      _onPanUpdate(details);
    } else {
      _handleState = 0;
    }

    return _handleState != 0;
  }

  int getHandle(position, touchWidth) {
    Offset handlerOffsetEnd = degreesToCoordinates(_painter!.center!,
        -math.pi / 2 + _startAngle + _currentAngle! + 1.5, _painter!.radius);
    Offset handlerOffsetStart = degreesToCoordinates(_painter!.center!,
        -math.pi / 2 + _startAngle + _startAngleOffset + 1.5, _painter!.radius);

    if (Rect.fromCenter(center: position, width: touchWidth, height: touchWidth)
        .contains(handlerOffsetEnd)) {
      return 2;
    } else if (Rect.fromCenter(
            center: position, width: touchWidth, height: touchWidth)
        .contains(handlerOffsetStart)) {
      return 1;
    } else {
      return 0;
    }
  }
}
