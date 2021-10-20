import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../utils.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  late List<double> chargeTime;
  late List<int> dischargeTime;

  @override
  void initState() {
    chargeTime = [timeToInt(1,59),timeToInt(5,30)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(child:
        SleekCircularSlider(

          onChangeStart: (double value) {},
          onChangeEnd: (double value) {},
          innerWidget: (double value){
            return Align(
              alignment: Alignment.center,
              child: SleekCircularSlider(
                onChangeStart: (double value) {},
                onChangeEnd: (double value) {},
                innerWidget: (double value){
                  return Container();
                },
                appearance: appearance02,
                min: 0,
                max: 60*24,
                touchOnTrack: true,
                initialStart: chargeTime[0],
                initialValue: chargeTime[1],
              ),
            );
          },
          appearance: appearance01,
          min: 0,
          max: 60*24,
          touchOnTrack: true,
          initialValue: 5,
        )),
      ),

    );
  }

  double timeToInt(double hr,double min){
    return hr*60 + min;
  }
}

final customWidth01 =
CustomSliderWidths(trackWidth: 2, progressBarWidth: 10, shadowWidth: 20);
final customColors01 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#FFD4BE').withOpacity(0.4),
    progressBarColor: HexColor('#F6A881'),
    shadowColor: HexColor('#FFD4BE'),
    shadowStep: 10.0,
    shadowMaxOpacity: 0.6);

final CircularSliderAppearance appearance01 = CircularSliderAppearance(
    customWidths: customWidth02,
    customColors: customColors01,
    startAngle: 270,
    angleRange: 360,
    size: 350.0,
    animationEnabled: false);


final customWidth02 =
CustomSliderWidths(trackWidth: 5, progressBarWidth: 15, shadowWidth: 30);
final customColors02 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#98DBFC').withOpacity(0.3),
    progressBarColor: HexColor('#6DCFFF'),
    shadowColor: HexColor('#98DBFC'),
    shadowStep: 15.0,
    shadowMaxOpacity: 0.3);

final CircularSliderAppearance appearance02 = CircularSliderAppearance(
    customWidths: customWidth02,
    customColors: customColors02,
    startAngle: 270,
    angleRange: 360,
    size: 290.0,
    animationEnabled: false);

final customWidth03 =
CustomSliderWidths(trackWidth: 8, progressBarWidth: 20, shadowWidth: 40);
final customColors03 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#EFC8FC').withOpacity(0.3),
    progressBarColor: HexColor('#A177B0'),
    shadowColor: HexColor('#EFC8FC'),
    shadowStep: 20.0,
    shadowMaxOpacity: 0.3);

final CircularSliderAppearance appearance03 = CircularSliderAppearance(
    customWidths: customWidth02,
    customColors: customColors03,
    startAngle: 270,
    angleRange: 360,
    size: 210.0,
    animationEnabled: false);
