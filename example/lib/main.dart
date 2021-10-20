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
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
      create: (context) => Counter(),
      child: const MyApp(),
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
    dischargeTime = [timeToInt(5, 30), timeToInt( 9, 50)];
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
      body: Center(
        child: Stack(
          children: <Widget>[

            // Consumer looks for an ancestor Provider widget
            // and retrieves its model (Counter, in this case).
            // Then it uses that model to build widgets, and will trigger
            // rebuilds if the model is updated.
            Consumer<Counter>(
              builder: (context, counter, child) => SleekCircularSlider(

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
                    startAngleOffset: intToDeg(counter.dischargeTime[0]),
                    size: 350.0,
                    animationEnabled: true),
                min: 0,
                max: 60 * 24,
                touchOnTrack: true,
                initialValue: counter.dischargeTime[1],
              ),
            ),
            Consumer<Counter>(
              builder: (context, counter, child) => Center(
                child: Center(
                  child: SleekCircularSlider(
                    onChangeStart: (s, e, p) {
                      // print("""
                      // $s
                      // $e
                      // $p
                      //                     """);
                    },
                    onChange: (s, e, p) async {
                      var counter = context.read<Counter>();
                      counter.randomise();
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
                        startAngleOffset: intToDeg(counter.chargeTime[0]),
                        angleRange: 360,
                        size: 290.0,
                        animationEnabled: true),
                    min: 0,
                    max: 60 * 24,
                    touchOnTrack: true,
                    initialValue: counter.chargeTime[1],
                  ),
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
          var counter = context.read<Counter>();
          counter.randomise();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
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
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#FFD4BE').withOpacity(0.4),
    progressBarColor: HexColor('#F6A881'),
    shadowColor: HexColor('#FFD4BE'),
    shadowStep: 10.0,
    shadowMaxOpacity: 0.6);


final customColors02 = CustomSliderColors(
    dotColor: Colors.white.withOpacity(0.8),
    trackColor: HexColor('#98DBFC').withOpacity(0.3),
    progressBarColor: HexColor('#6DCFFF'),
    shadowColor: HexColor('#98DBFC'),
    shadowStep: 15.0,
    shadowMaxOpacity: 0.3);