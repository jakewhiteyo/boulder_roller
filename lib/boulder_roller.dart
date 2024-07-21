import 'dart:async';

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
  late AnimationController characterWalkAnimationController;
  late AnimationController characterFallAnimationController;
  late AnimationController mountainAnimationController;
  late FocusNode focusNode;

  late Animation<int> sisyphusWalkFrame;
  late Animation<int> sisyphusFallFrame;
  late Animation<int> mountainFrame;

  final int walkFrames = 15;
  final int fallFrames = 8;
  final int mountainFrames = 60;
  final double fps = 10;
  final int fallDurationSeconds = 2;
  Timer? reverseTimer;

  bool isFalling = false;
  // late Animation<double> sisyphusX;
  // late Animation<double> sisyphusY;

  @override
  void initState() {
    super.initState();

    characterWalkAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (1000 * walkFrames / fps).round()));

    characterFallAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (1000 * fallFrames / fps).round()));

    mountainAnimationController = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: (1000 * mountainFrames / fps).round()));

    sisyphusWalkFrame = IntTween(begin: 1, end: walkFrames)
        .animate(characterWalkAnimationController);
    mountainFrame = IntTween(begin: 1, end: mountainFrames)
        .animate(mountainAnimationController);
    sisyphusFallFrame = IntTween(begin: 1, end: fallFrames)
        .animate(characterFallAnimationController);

    focusNode = FocusNode();
  }

  @override
  void dispose() {
    characterWalkAnimationController.dispose();
    focusNode.dispose();
    reverseTimer?.cancel();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          if (!characterWalkAnimationController.isAnimating) {
            characterWalkAnimationController.reset();
            characterWalkAnimationController.repeat();
            // mountainAnimationController.reset();
            mountainAnimationController.repeat();
            reverseTimer?.cancel();
          }
      }
    } else if (event is RawKeyUpEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          // end walk-up animation, begin fall animation
          characterWalkAnimationController.stop();
          mountainAnimationController.stop();
          _startMountainReverseAnimation();

          // mountainAnimationController.reverse(
          //     from: mountainAnimationController.value);
          characterFallAnimationController.reset();
          characterFallAnimationController.repeat();
          setState(() {
            isFalling = true;
          });

          // start timer for sisyphus to fall
          reverseTimer = Timer(Duration(seconds: fallDurationSeconds), () {
            characterFallAnimationController.stop();
            mountainAnimationController.stop();
            setState(() {
              isFalling = false;
            });
          });
      }
    }
  }

  void _startMountainReverseAnimation() {
    mountainAnimationController.reverse(
        from: mountainAnimationController.value);
    mountainAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && isFalling) {
        mountainAnimationController.reverse(from: 1.0);
      }
    });
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
                  animation: isFalling
                      ? characterFallAnimationController
                      : characterWalkAnimationController,
                  builder: (BuildContext context, Widget? child) {
                    return Positioned(
                      left: screenWidthMiddle,
                      top: screenHeightMiddle - 100,
                      child: Transform.scale(
                        scale: 2,
                        child: Image(
                          image: AssetImage(isFalling
                              ? "assets/Fall-Animation${sisyphusFallFrame.value}.png"
                              : "assets/Walk${sisyphusWalkFrame.value}.png"),
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
