// import 'package:flutter/material.dart';
// import 'ui/home_page.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Sleek Circular Slider',
//       debugShowCheckedModeBanner: false,
//       home: HomePage(),
//     );
//   }
// }

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:example/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'multi_track.dart';

void main() {
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => MultiTrackNotifier(),
      child: const MultiTrackApp(),
    ),
  );
}

/// Simplest possible model, with just one field.
///
/// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
/// _not_ depend on Provider.
class Counter with ChangeNotifier {
  List<double> dischargeTime = [timeToInt(1, 30), timeToInt(4, 50)];
  List<double> chargeTime = [timeToInt(5, 0), timeToInt(9, 0)];

  void randomise() {
    chargeTime = [
      timeToInt(
          Random().nextInt(23).toDouble(), Random().nextInt(59).toDouble()),
      timeToInt(
          Random().nextInt(23).toDouble(), Random().nextInt(59).toDouble())
    ];
    dischargeTime = [chargeTime[1], chargeTime[0]];
    notifyListeners();
  }

  void moveInter(s, e, p) {
    chargeTime = [s, e];
    if ((dischargeTime[1] - chargeTime[0]) % 1440 < 80) {
      dischargeTime[1] = s;
    }
    if (((chargeTime[1] - dischargeTime[0])) % 1440 < 80) {
      dischargeTime[0] = e;
    }
    notifyListeners();
  }

  void moveOuter(s, e, p) {
    dischargeTime = [s, e];
    if ((dischargeTime[1] - chargeTime[0]) % 1440 < 80) {
      chargeTime[0] = e;
    }
    if (((chargeTime[1] - dischargeTime[0])) % 1440 < 80) {
      chargeTime[1] = s;
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

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
            Stack(
              children: <Widget>[
                Consumer<Counter>(
                  builder: (context, counter, child) => Center(
                    child: SleekCircularSlider(
                      onChange: (s, e, p) async {
                        var counter = context.read<Counter>();
                        counter.moveOuter(s, e, p);
                      },
                      onChangeStart: (s, e, p) {},
                      onChangeEnd: (s, e, p) {},
                      appearance: CircularSliderAppearance(
                          customWidths: customWidth02,
                          customColors: customColors01,
                          // startAngle: 270,
                          angleRange: 360,
                          startAngleOffset: intToDeg(counter.dischargeTime[0]),
                          size: 350.0,
                          animationEnabled: true),
                      min: 0,
                      max: 60 * 24,
                      touchOnTrack: true,
                      innerWidget: (double value) {
                        return Center(
                          child: SleekCircularSlider(
                            onChangeStart: (s, e, p) {},
                            onChange: (s, e, p) async {
                              var counter = context.read<Counter>();
                              counter.moveInter(s, e, p);
                            },
                            onChangeEnd: (s, e, p) {
                              // print("""
                              // $s
                              // $e
                              // $p
                              // """);
                            },
                            innerWidget: (double value) {
                              return Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${doubleToTime(counter.chargeTime[0])} ${doubleToTime(counter.chargeTime[1])}'),
                                  Text(
                                      '${doubleToTime(counter.dischargeTime[0])} ${doubleToTime(counter.dischargeTime[1])}'),
                                ],
                              ));
                            },
                            appearance: CircularSliderAppearance(
                                customWidths: customWidth02,
                                customColors: customColors02,
                                // startAngle: 270,
                                startAngleOffset:
                                    intToDeg(counter.chargeTime[0]),
                                angleRange: 360,
                                size: 290.0,
                                animationEnabled: true),
                            min: 0,
                            max: 60 * 24,
                            touchOnTrack: true,
                            startValue: counter.chargeTime[0],
                            sweepValue: counter.chargeTime[1],
                            externalRestrictions: counter.dischargeTime
                                .map((x) => intToDeg(x))
                                .toList(),
                          ),
                        );
                      },
                      startValue: counter.dischargeTime[0],
                      sweepValue: counter.dischargeTime[1],
                      externalRestrictions:
                          counter.chargeTime.map((x) => intToDeg(x)).toList(),
                    ),
                  ),
                ),
                // Consumer<Counter>(
                //   builder: (context, counter, child) => Center(
                //     child: Center(
                //       child: SleekCircularSlider(
                //         onChangeStart: (s, e, p) {
                //         },
                //         onChange: (s, e, p) async {
                //           var counter = context.read<Counter>();
                //           counter.moveInter(s,e,p);
                //         },
                //         onChangeEnd: (s, e, p) {
                //           // print("""
                //           // $s
                //           // $e
                //           // $p
                //           // """);
                //         },
                //         innerWidget: (double value) {
                //           return Center(child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Text('${doubleToTime(counter.chargeTime[0])} ${doubleToTime(counter.chargeTime[1])}'),
                //               Text('${doubleToTime(counter.dischargeTime[0])} ${doubleToTime(counter.dischargeTime[1])}'),
                //             ],
                //           ));
                //         },
                //         appearance: CircularSliderAppearance(
                //             customWidths: customWidth02,
                //             customColors: customColors02,
                //             startAngle: 270,
                //             startAngleOffset: intToDeg(counter.chargeTime[0]),
                //             angleRange: 360,
                //             size: 290.0,
                //             animationEnabled: true),
                //         min: 0,
                //         max: 60 * 24,
                //         touchOnTrack: true,
                //         initialStart: counter.chargeTime[0],
                //         initialValue: counter.chargeTime[1],
                //         externalRestrictions: counter.dischargeTime.map( (x)=>intToDeg(x)).toList(),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            Consumer<Counter>(
                builder: (context, counter, child) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Charge Time : From ${timeToString(doubleToTime(counter.chargeTime[0]))} To  ${timeToString(doubleToTime(counter.chargeTime[1]))}',
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: Colors.white, letterSpacing: .5),
                            ),
                          ),
                          Text(
                            'Discharge Time : From ${timeToString(doubleToTime(counter.dischargeTime[0]))} To ${timeToString(doubleToTime(counter.dischargeTime[1]))}',
                            style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  color: Colors.white, letterSpacing: .5),
                            ),
                          ),
                        ],
                      ),
                    )),
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
          var counter = context.read<Counter>();
          counter.randomise();
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
