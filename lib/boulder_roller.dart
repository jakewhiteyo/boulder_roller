import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class BoulderRoller extends StatefulWidget {
  const BoulderRoller({super.key});

  @override
  State<StatefulWidget> createState() => BoulderRollerState();
}

class BoulderRollerState extends State<BoulderRoller>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late FocusNode focusNode;

  late Animation<int> sisyphusFrame;
  // late Animation<double> sisyphusX;
  // late Animation<double> sisyphusY;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 8));

    sisyphusFrame = TweenSequence<int>(
            [TweenSequenceItem(tween: walkAnimation(), weight: 1)])
        .animate(animationController);

    focusNode = FocusNode();

    //animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  walkAnimation() => TweenSequence([
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
        TweenSequenceItem(tween: StepTween(begin: 1, end: 15), weight: 1),
      ]);

  void _handleKeyEvent(RawKeyEvent event) {
    print(event.logicalKey);
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          if (!animationController.isAnimating) {
            animationController.reset();
            animationController.forward();
          }
      }
    } else if (event is RawKeyUpEvent) {
      switch (event.logicalKey) {
        case (LogicalKeyboardKey.arrowRight):
          animationController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidthMiddle = MediaQuery.of(context).size.width / 2;
    double screenHeightMiddle = MediaQuery.of(context).size.height / 2;
    return Scaffold(
        backgroundColor: Colors.lightBlue,
        body: RawKeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            onKey: _handleKeyEvent,
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: animationController,
                  builder: (BuildContext context, Widget? child) {
                    return Positioned(
                        left: screenWidthMiddle,
                        top: screenHeightMiddle - 100,
                        child: Transform.scale(
                            scale: 2,
                            child: Image(
                              image: AssetImage(
                                  "assets/Walk${sisyphusFrame.value}.png"),
                              gaplessPlayback:
                                  true, // if this value changes while the image is still loading it will continue to display the previous value
                            )));
                  },
                )
              ],
            )));
  }
}
