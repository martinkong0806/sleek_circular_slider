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
  late List<double> dischargeTime;

  Key outerCircleKey = Key('outerCircle');

  @override
  void initState() {
    chargeTime = [timeToInt(5, 0), timeToInt(9, 0)];
    dischargeTime = [timeToInt(1, 30), timeToInt(4, 50)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
            child: Stack(
          children: [
            Center(
              child: SleekCircularSlider(
                key: outerCircleKey,
                onChange: (s, e, p) async {
                  // Future.delayed(Duration.zero, () async {
                  //   setState(() {
                  //     dischargeTime[0] = e;
                  //   });
                  //   if(p==2){
                  //     if(chargeTime[0]>=dischargeTime[1]){
                  //       setState(() {
                  //         chargeTime[0] = dischargeTime[1] ;
                  //       });
                  //     }
                  //   }
                  // });
                },
                onChangeStart: (s, e, p) {},
                onChangeEnd: (s, e, p) {},
                appearance: CircularSliderAppearance(
                    customWidths: customWidth02,
                    customColors: customColors01,
                    startAngle: 270,
                    angleRange: 360,
                    startAngleOffset: intToDeg(dischargeTime[0]),
                    size: 350.0,
                    animationEnabled: true),
                min: 0,
                max: 60 * 24,
                touchOnTrack: true,
                initialValue: dischargeTime[1],
              ),
            ),
            Center(
              child: SleekCircularSlider(
                onChangeStart: (s, e, p) {
                  // print("""
                  // $s
                  // $e
                  // $p
                  //                     """);
                },
                onChange: (s, e, p) async {

                  //  Future.delayed(Duration.zero, () async {
                  // //    print("""
                  // // $e
                  // // $s
                  // //  """);
                  //
                  //    if(p==1){
                  //      // setState(() {
                  //      //   chargeTime = [s,e];
                  //      //
                  //      //
                  //      // });
                  //      // if(chargeTime[0]<=dischargeTime[1]){
                  //      //   setState(() {
                  //      //     dischargeTime[1] = chargeTime[0];
                  //      //   });
                  //      // }
                  //    }
                  //  });

                  setState(() {
                    chargeTime = [s, e];
                  });
                  if (p == 1) {
                    setState(() {
                      chargeTime = [s, e];
                    });

                    if (chargeTime[0] <= dischargeTime[1]) {
                      setState(() {});
                    }
                  }

                  // if(p==2){
                  //   if(chargeTime[1]<=dischargeTime[1]){
                  //     setState(() {
                  //       dischargeTime[1] = chargeTime[0];
                  //     });
                  //   }
                  // }
                },
                onChangeEnd: (s, e, p) {
                  // print("""
                  // $s
                  // $e
                  // $p
                  // """);
                },
                innerWidget: (double value) {
                  return Container();
                },
                appearance: CircularSliderAppearance(
                    customWidths: customWidth02,
                    customColors: customColors02,
                    startAngle: 270,
                    startAngleOffset: intToDeg(chargeTime[0]),
                    angleRange: 360,
                    size: 290.0,
                    animationEnabled: true),
                min: 0,
                max: 60 * 24,
                touchOnTrack: true,
                initialValue: chargeTime[1],
              ),
            )
          ],
        )),
      ),
      // floatingActionButton: TextButton(onPressed: ()async{
      //   Future.delayed(Duration.zero, () async {
      //     setState(() {
      //       chargeTime = [360,720];
      //     });
      //   });
      //
      // },child: Text("Rand"),),
    );
  }

  double timeToInt(double hr, double min) {
    return hr * 60 + min;
  }

  List<int> doubleToTime(double value) {
    return [value ~/ 60, value ~/ 1 % 60];
  }

  double intToDeg(double i) {
    return i / (60 * 24) * 360;
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
    trackColor: HexColor('#EFC8FC').withOpacity(0),
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
