import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'package:example/utils.dart';

class MultiTrackNotifier with ChangeNotifier {
  List<double> dischargeTime1 = [timeToInt(1, 0), timeToInt(2, 30)];
  List<double> dischargeTime2 = [timeToInt(5, 0), timeToInt(9, 0)];

  void randomize() {
    dischargeTime1 = [timeToInt(4, 50), timeToInt(9, 50)];
    notifyListeners();
  }
}

class MultiTrackApp extends StatelessWidget {
  const MultiTrackApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MultiTrackNotifierPage(),
    );
  }
}

class MultiTrackNotifierPage extends StatelessWidget {
  const MultiTrackNotifierPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<MultiTrackNotifier>(
              builder: (context, counter, child) => Center(
                child: SleekCircularSlider(
                  onChange: (s, e, p) async {
                    // var counter = context.read<MultiTrackNotifier>();
                    // counter.moveOuter(s, e, p);
                  },
                  onChangeStart: (s, e, p) {},
                  onChangeEnd: (s, e, p) {},
                  appearance: CircularSliderAppearance(
                      animDurationMultiplier: 3,
                      customWidths: customWidth02,
                      customColors: customColors01,
                      startAngleOffset: 270,
                      angleRange: 360,
                      // startAngleOffset: intToDeg(counter.dischargeTime1[0]),
                      size: 350.0,
                      animationEnabled: true),
                  min: 0,
                  max: 60 * 24,
                  touchOnTrack: true,
                  innerWidget: (double value) {
                    return Container();
                  },
                  startValue: counter.dischargeTime1[0],
                  sweepValue: counter.dischargeTime1[1],
                  // externalRestrictions:
                  //     counter.chargeTime.map((x) => intToDeg(x)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var counter = context.read<MultiTrackNotifier>();

          counter.randomize();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

String timeToString(List<int> val) {
  String hr = val[0] > 9 ? '${val[0]}' : '0${val[0]}';
  String min = val[1] > 9 ? '${val[1]}' : '0${val[1]}';

  return '$hr : $min';
}

double intToDeg(double i) {
  return i / (60 * 24) * 360;
}

double timeToInt(double hr, double min) {
  return hr * 60 + min;
}

final customWidth02 =
    CustomSliderWidths(trackWidth: 5, progressBarWidth: 15, shadowWidth: 30);
final customColors01 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.5),
    trackColor: HexColor('#000000').withOpacity(0.1),
    progressBarColor: HexColor('#76E2FF').withOpacity(0.5),
    // progressBarColors: [
    //   HexColor('#76E2FF').withOpacity(0.5),
    //   // HexColor('#4E09ED').withOpacity(0.5),
    //   // HexColor('#F7E4FF').withOpacity(0.3)
    // ],
    dynamicGradient: true,
    shadowColor: HexColor('#55B3E4'),
    shadowMaxOpacity: 0.02);

final customColors02 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.5),
    trackColor: HexColor('#000000').withOpacity(0.1),
    progressBarColor: HexColor('#4E09ED').withOpacity(0.5),
    // progressBarColors: [
    //   HexColor('#76E2FF').withOpacity(0.5),
    //   // HexColor('#4E09ED').withOpacity(0.5),
    //   // HexColor('#F7E4FF').withOpacity(0.3)
    // ],
    dynamicGradient: true,
    shadowColor: HexColor('#55B3E4'),
    shadowMaxOpacity: 0.02);

List<int> doubleToTime(double value) {
  return [value ~/ 60, value ~/ 1 % 60];
}
