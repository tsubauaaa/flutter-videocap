import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  const CameraView({Key key, this.cameras}) : super(key: key);
  final List<CameraDescription> cameras;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController controller;

  Timer timer;

  @override
  void initState() {
    super.initState();
    if (widget.cameras == null) return;
    controller = CameraController(widget.cameras.first, ResolutionPreset.high);
    controller.initialize();

    timer = Timer.periodic(
      Duration(seconds: 30),
      (Timer t) async {},
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      child: CameraPreview(controller),
    );
  }
}
