import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraPreviewTopPage extends StatefulWidget {
  const CameraPreviewTopPage({
    Key key,
    @required this.camera,
  }) : super(key: key);
  final CameraDescription camera;

  @override
  CameraPreviewTopPageState createState() => CameraPreviewTopPageState();
}

class CameraPreviewTopPageState extends State<CameraPreviewTopPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            if (_controller.value.isRecordingVideo) {
              XFile video = await _controller.stopVideoRecording();
              print(video.path);
              return;
            }
            try {
              await _controller.startVideoRecording();
            } on CameraException catch (e) {
              print(e);
            }
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
