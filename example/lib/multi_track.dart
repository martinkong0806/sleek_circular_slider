import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:provider/provider.dart';
import 'package:example/utils.dart';

class MultiTrackNotifier with ChangeNotifier {
  List<double> dischargeTime1 = [timeToInt(1, 30), timeToInt(4, 50)];
  List<double> dischargeTime2 = [timeToInt(5, 0), timeToInt(9, 0)];
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
                      customWidths: customWidth02,
                      customColors: customColors01,
                      startAngle: 270,
                      angleRange: 360,
                      startAngleOffset: intToDeg(counter.dischargeTime1[0]),
                      size: 350.0,
                      animationEnabled: true),
                  min: 0,
                  max: 60 * 24,
                  touchOnTrack: true,
                  innerWidget: (double value) {
                    return Container();
                  },
                  initialStart: counter.dischargeTime1[0],
                  initialValue: counter.dischargeTime1[1],
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
          // You can access your providers anywhere you have access
          // to the context. One way is to use Provider.of<Counter>(context).
          //
          // The provider package also defines extension methods on context
          // itself. You can call context.watch<Counter>() in a build method
          // of any widget to access the current state of Counter, and to ask
          // Flutter to rebuild your widget anytime Counter changes.
          //
          // You can't use context.watch() outside build methods, because that
          // often leads to subtle bugs. Instead, you should use
          // context.read<Counter>(), which gets the current state
          // but doesn't ask Flutter for future rebuilds.
          //
          // Since we're in a callback that will be called whenever the user
          // taps the FloatingActionButton, we are not in the build method here.
          // We should use context.read().
          var counter = context.read<MultiTrackNotifier>();
          // counter.randomise();
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
