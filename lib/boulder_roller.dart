import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BoulderRoller extends StatefulWidget {
  const BoulderRoller({super.key});

  @override
  State<StatefulWidget> createState() => BoulderRollerState();
}

class BoulderRollerState extends State<BoulderRoller>
    with TickerProviderStateMixin {
  late AnimationController characterAnimationController;
  late AnimationController mountainAnimationController;
  late FocusNode focusNode;

  late Animation<int> sisyphusFrame;
  late Animation<int> mountainFrame;

  final int walkFrames = 15;
  final int mountainFrames = 60;
  final double walkFps = 10;
  final double mountainFps = 10;
  // late Animation<double> sisyphusX;
  // late Animation<double> sisyphusY;

  @override
  void initState() {
    super.initState();

    characterAnimationController = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (1000 * walkFrames / walkFps).round()));

    mountainAnimationController = AnimationController(
        vsync: this,
        duration: Duration(
            milliseconds: (1000 * mountainFrames / mountainFps).round()));

    sisyphusFrame = IntTween(begin: 1, end: walkFrames)
        .animate(characterAnimationController);
    mountainFrame = IntTween(begin: 1, end: mountainFrames)
        .animate(mountainAnimationController);

    focusNode = FocusNode();

    //animationController.repeat();
  }

  @override
  void dispose() {
    characterAnimationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    print(event.logicalKey);
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          if (!characterAnimationController.isAnimating) {
            characterAnimationController.reset();
            characterAnimationController.repeat();
            mountainAnimationController.reset();
            mountainAnimationController.repeat();
          }
      }
    } else if (event is RawKeyUpEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          characterAnimationController.stop();
          mountainAnimationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidthMiddle = MediaQuery.of(context).size.width / 2;
    double screenHeightMiddle = MediaQuery.of(context).size.height / 2;

    // Precache images to improve performance
    for (int i = 1; i <= mountainFrames; i++) {
      precacheImage(AssetImage("assets/Mountain$i.png"), context);
    }
    for (int i = 1; i <= walkFrames; i++) {
      precacheImage(AssetImage("assets/Walk$i.png"), context);
    }

    return Scaffold(
        backgroundColor: Colors.lightBlue,
        body: RawKeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            onKey: _handleKeyEvent,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: mountainAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return Positioned(
                      left: screenWidthMiddle - 450,
                      top: screenHeightMiddle - 250,
                      child: Transform.scale(
                        scale: 2,
                        child: Image(
                          image: AssetImage(
                              "assets/Mountain${mountainFrame.value}.png"),
                          gaplessPlayback: true,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: characterAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return Positioned(
                      left: screenWidthMiddle,
                      top: screenHeightMiddle - 100,
                      child: Transform.scale(
                        scale: 2,
                        child: Image(
                          image: AssetImage(
                              "assets/Walk${sisyphusFrame.value}.png"),
                          gaplessPlayback: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            )));
  }
}
