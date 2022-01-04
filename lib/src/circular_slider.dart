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

typedef void OnChange(double startPoint, double endPoint, HandleState state);
typedef Widget InnerWidget(double percentage);

class SleekCircularSlider extends StatefulWidget {
  final double startValue;
  final double sweepValue;
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

  double get startAngle {
    return valueToAngle(startValue, min, max, appearance.angleRange);
  }

  double get sweepAngle {
    return valueToAngle(sweepValue, min, max, appearance.angleRange);
  }

  const SleekCircularSlider(
      {Key? key,
      this.startValue = 0,
      this.sweepValue = 50,
      this.min = 0,
      this.max = 100,
      this.touchOnTrack = true,
      this.appearance = defaultAppearance,
      this.onChange,
      this.onChangeStart,
      this.onChangeEnd,
      this.innerWidget,
      this.externalRestrictions})
      : assert(min <= max),
        assert(sweepValue >= min && sweepValue <= max),
        super(key: key);
  @override
  _SleekCircularSliderState createState() => _SleekCircularSliderState();
}

enum HandleState { INACTIVE, ACTIVE_START, ACTIVE_END }

extension HandleStateExtension on HandleState {
  bool get isActive => this != HandleState.INACTIVE;
}

class _SleekCircularSliderState extends State<SleekCircularSlider>
    with SingleTickerProviderStateMixin {
  HandleState _handleState = HandleState.INACTIVE;
  bool _animationInProgress = false;
  _CurvePainter? _painter;
  double? _oldWidgetStartAngle;
  double? _oldWidgetStartValue;
  double? _oldWidgetSweepAngle;
  double? _oldWidgetSweepValue;
  double? _currentStartAngle;
  double? _currentSweepAngle;
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
    _startAngle = widget.startAngle;
    _startAngleOffset = widget.appearance.startAngleOffset;

    // _startAngle = widget.appearance.startAngle;
    _angleRange = widget.appearance.angleRange;
    _appearanceHashCode = widget.appearance.hashCode;

    _currentStartAngle = widget.startAngle;
    _currentSweepAngle = widget.sweepAngle;

    if (!widget.appearance.animationEnabled) {
      return;
    }

    widget.appearance.spinnerMode ? _spin() : _animate();
  }

  @override
  void didUpdateWidget(SleekCircularSlider oldWidget) {
    _setupPainter(passive: true);

    if (oldWidget.sweepAngle != widget.sweepAngle &&
        _currentSweepAngle?.toStringAsFixed(4) !=
            widget.sweepAngle.toStringAsFixed(4)) {
      _animate(oldWidget: oldWidget);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _animate({SleekCircularSlider? oldWidget}) {
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
    if (oldWidget != null) {
      _oldWidgetStartAngle = oldWidget.startAngle;
      _oldWidgetStartValue = oldWidget.startValue;
      _oldWidgetSweepAngle = oldWidget.sweepAngle;
      _oldWidgetSweepValue = oldWidget.sweepValue;
    }

    _animationManager!.animate(
        initialValue: widget.sweepValue,
        angle: widget.sweepAngle,
        oldStartAngle: _oldWidgetStartAngle,
        oldStartValue: _oldWidgetStartValue,
        oldSweepAngle: _oldWidgetSweepAngle,
        oldSweepValue: _oldWidgetSweepValue,
        valueChangedAnimation: ((double anim, bool animationCompleted) {
          _animationInProgress = !animationCompleted;

          setState(() {
            if (!animationCompleted) {
              _currentSweepAngle = anim;
              // update painter and the on change closure
              _setupPainter();
              _updateOnChange();
            }
          });
        }));
    // _oldWidgetAngle = widget.sweepAngle;
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
            _currentSweepAngle = anim3;
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
    // double defaultStartAngle = _currentStartAngle ?? widget.startAngle;
    // double defaultSweepAngle = _currentSweepAngle ?? widget.sweepAngle;
    // if (_oldWidgetSweepAngle != null) {
    //   if (_oldWidgetSweepAngle != widget.sweepAngle) {
    //     _selectedAngle = null;
    //     defaultSweepAngle = widget.sweepAngle;
    //   }

    //   if (_oldWidgetStartAngle != null) {
    //     if (_oldWidgetStartAngle != widget.startAngle) {
    //       _selectedAngle = null;
    //       defaultStartAngle = widget.startAngle;
    //     }
    //   }
    // }

    // if (_currentStartAngle == null) _currentStartAngle = 0;

    /// This code will only occurs when external sliders is
    /// affecting this slider
    // if (passive) {
    //   _startAngleOffset = calculateAngle(
    //       startAngle: _startAngle,
    //       angleRange: _angleRange,
    //       selectedAngle:
    //           degreeToRadians((widget.startAngle + _startAngle) % 360),
    //       defaultAngle: defaultAngle,
    //       counterClockwise: counterClockwise);
    // }

    /// calculate the angle derived from the gesture.

    if (_handleState == HandleState.ACTIVE_END) {
      // print((radiansToDegrees(_selectedAngle!) -
      //         _startAngleOffset -
      //         _currentStartAngle! +
      //         360) %
      //     360);
      // double gestureCalcAngle = calculateAngle(
      //     startAngle: _currentStartAngle!,
      //     startAngleOffset: _startAngleOffset,
      //     angleRange: _angleRange,
      //     selectedAngle: _selectedAngle,
      //     defaultAngle: widget.sweepAngle,
      //     counterClockwise: counterClockwise);

      _currentSweepAngle = math.max(
          (radiansToDegrees(_selectedAngle!) -
                  _startAngleOffset -
                  _currentStartAngle! +
                  360) %
              360, 10) ;
      
    }

    if (_handleState == HandleState.ACTIVE_START) {
      double angle = calculateAngle(
          startAngle: _currentStartAngle!,
          startAngleOffset: _startAngleOffset,
          angleRange: _angleRange,
          selectedAngle: _selectedAngle,
          defaultAngle: widget.startAngle,
          counterClockwise: counterClockwise);
      _currentSweepAngle = _currentSweepAngle! + _currentStartAngle!;
      _currentStartAngle = angle;
      _currentSweepAngle =
          math.max((_currentSweepAngle! - _currentStartAngle!) % 360, 10);
    }

    _painter = _CurvePainter(
        startAngle: _currentStartAngle!,
        startAngleOffset: _startAngleOffset,
        angleRange: _angleRange,
        sweepAngle: _currentSweepAngle!,
        appearance: widget.appearance);
    _oldWidgetSweepAngle = widget.sweepAngle;
    _oldWidgetSweepValue = widget.sweepValue;
  }

  void _updateOnChange() {
    if (widget.onChange != null && !_animationInProgress) {
      final value = angleToValue(
          _currentSweepAngle!, widget.min, widget.max, _angleRange);
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
        angleToValue(_currentSweepAngle!, widget.min, widget.max, _angleRange);
    final childWidget = widget.innerWidget != null
        ? widget.innerWidget!(value)
        : SliderLabel(
            value: value,
            appearance: widget.appearance,
          );
    return childWidget;
  }

  void _onPanUpdate(Offset details) {
    if (_handleState == HandleState.INACTIVE) {
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
          angleToValue(
              _currentSweepAngle!, widget.min, widget.max, _angleRange),
          _handleState);
    }

    _handleState = HandleState.INACTIVE;
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

    _selectedAngle = coordinatesToRadians(_painter!.center!, position);

    // print(_currentSweepAngle);

    if (isPointAlongCircle(
        position, _painter!.center!, _painter!.radius, touchWidth)) {
      // _selectedAngle = coordinatesToRadians(_painter!.center!, position);
    }

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
        startAngle: _currentStartAngle!,
        startAngleOffset: _startAngleOffset,
        angleRange: _angleRange,
        touchAngle: coordinatesToRadians(_painter!.center!, position),
        previousAngle: _currentSweepAngle,
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
            angleToValue(
                _currentSweepAngle!, widget.min, widget.max, _angleRange),
            _handleState);
      }

      _positionOnChangeStart = [_startAngleOffset, _currentSweepAngle!];
      _onPanUpdate(details);
    } else {
      _handleState = HandleState.INACTIVE;
    }

    return _handleState.isActive;
  }

  HandleState getHandle(position, touchWidth) {
    Offset handlerOffsetEnd = degreesToCoordinates(
        _painter!.center!,
        _currentStartAngle! + _startAngleOffset + _currentSweepAngle! - 1.5,
        _painter!.radius);
    Offset handlerOffsetStart = degreesToCoordinates(_painter!.center!,
        _currentStartAngle! + _startAngleOffset + 1.5, _painter!.radius);

    if (Rect.fromCenter(center: position, width: touchWidth, height: touchWidth)
        .contains(handlerOffsetEnd)) {
      return HandleState.ACTIVE_END;
    } else if (Rect.fromCenter(
            center: position, width: touchWidth, height: touchWidth)
        .contains(handlerOffsetStart)) {
      return HandleState.ACTIVE_START;
    } else {
      return HandleState.INACTIVE;
    }
  }
}
