import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlinkingTextAnimation extends StatefulWidget {
  const BlinkingTextAnimation({Key? key}) : super(key: key);

  @override
  _BlinkingTextAnimationState createState() => _BlinkingTextAnimationState();
}

class _BlinkingTextAnimationState extends State<BlinkingTextAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> animation;
  AnimationController? controller;

  initState() {
    super.initState();

    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);

    final CurvedAnimation curve =
        CurvedAnimation(parent: controller!, curve: Curves.ease);

    animation = ColorTween(begin: Colors.white, end: Colors.red).animate(curve);

    animation!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller!.forward();
      }
      setState(() {});
    });

    controller!.forward();
  }

  dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.circle_fill,
              color: animation.value,
            ),
            const SizedBox(
              width: 4,
            ),
            const Text(
              'REC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
              ),
            ),
          ],
        );
      },
    );
  }
}
